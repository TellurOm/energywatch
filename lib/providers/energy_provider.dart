import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/calculations.dart';
import '../data/mock_energy_data.dart';
import '../models/energy_reading.dart';
import '../models/appliance.dart';
import '../models/billing_rate.dart';
import '../models/savings_tip.dart';
import '../repositories/energy_repository.dart';

/// Supported filter ranges for consumption analysis.
enum ConsumptionFilter {
  sevenDays,
  thirtyDays,
  ninetyDays,
  today,
  thisWeek,
  thisMonth,
  custom,
}

/// Simulation speed controls for demo presentations.
enum SimulationSpeed {
  normal, // ~6 seconds
  fast, // ~2 seconds
  paused, // no updates
}

/// Central state provider for the EnergyWatch application.
/// Manages live simulated meter readings, historical analytics, appliance data,
/// billing estimations, and conservation tips.
class EnergyProvider extends ChangeNotifier {
  final EnergyRepository _repository;

  EnergyProvider({EnergyRepository? repository})
      : _repository = repository ?? EnergyRepository() {
    _initializeData();
  }

  // State Fields
  bool _isLoading = true;
  String? _errorMessage;
  List<EnergyReading> _allReadings = [];
  List<EnergyReading> _todayHourlyReadings = [];
  List<Appliance> _appliances = [];
  BillingRate _billingRate = MockEnergyData.defaultBillingRate;
  List<SavingsTip> _savingsTips = [];

  ConsumptionFilter _selectedFilter = ConsumptionFilter.sevenDays;
  DateTimeRange? _customDateRange;
  Appliance? _selectedAppliance;

  // Live Meter Simulation
  double _currentPowerKw = 1.84;
  DateTime _lastUpdated = DateTime.now();
  SimulationSpeed _simulationSpeed = SimulationSpeed.normal;
  Timer? _simulationTimer;
  final Random _random = Random();

  // Theme State
  ThemeMode _themeMode = ThemeMode.light;

  // Fixed Historical Baselines for realistic comparisons
  final double _yesterdayConsumption = 7.10;
  final double _previousMonthConsumption = 201.7;
  final double _previousWeekConsumption = 51.8;
  final double _projectedMonthlyConsumption = 194.2;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EnergyReading> get allReadings => _allReadings;
  List<EnergyReading> get todayHourlyReadings => _todayHourlyReadings;
  List<Appliance> get appliances => _appliances;
  BillingRate get billingRate => _billingRate;
  List<SavingsTip> get savingsTips => _savingsTips;
  ConsumptionFilter get selectedFilter => _selectedFilter;
  DateTimeRange? get customDateRange => _customDateRange;
  Appliance? get selectedAppliance => _selectedAppliance;
  double get currentPowerKw => _currentPowerKw;
  DateTime get lastUpdated => _lastUpdated;
  SimulationSpeed get simulationSpeed => _simulationSpeed;
  ThemeMode get themeMode => _themeMode;

  double get yesterdayConsumption => _yesterdayConsumption;
  double get previousMonthConsumption => _previousMonthConsumption;
  double get previousWeekConsumption => _previousWeekConsumption;
  double get projectedMonthlyConsumption => _projectedMonthlyConsumption;

  // Computed Properties

  /// Today's consumption: sum of today's hourly readings (6.72 kWh)
  double get todayConsumption {
    if (_todayHourlyReadings.isNotEmpty) {
      return Calculations.calculateTotalConsumption(
        _todayHourlyReadings.map((r) => r.energyKwh).toList(),
      );
    }
    return 6.72;
  }

  /// Percentage change today vs yesterday (-5.35%)
  double get todayChangePercent {
    return Calculations.calculatePercentageChange(todayConsumption, _yesterdayConsumption);
  }

  /// Total monthly consumption: 184.5 kWh
  double get monthlyConsumption {
    if (_allReadings.isNotEmpty) {
      return Calculations.calculateTotalConsumption(
        _allReadings.map((r) => r.energyKwh).toList(),
      );
    }
    return 184.5;
  }

  /// Current week consumption (47.6 kWh)
  double get currentWeekConsumption {
    final recent7 = getFilteredReadingsForFilter(ConsumptionFilter.sevenDays);
    if (recent7.isNotEmpty) {
      return Calculations.calculateTotalConsumption(
        recent7.map((r) => r.energyKwh).toList(),
      );
    }
    return 47.6;
  }

  /// Weekly change vs previous week (-8.1%)
  double get weekChangePercent {
    return Calculations.calculatePercentageChange(currentWeekConsumption, _previousWeekConsumption);
  }

  /// Returns energy readings filtered by the current selected filter
  List<EnergyReading> get filteredReadings {
    return getFilteredReadingsForFilter(_selectedFilter);
  }

  List<EnergyReading> getFilteredReadingsForFilter(ConsumptionFilter filter) {
    if (_allReadings.isEmpty) return [];

    switch (filter) {
      case ConsumptionFilter.today:
        return _todayHourlyReadings;
      case ConsumptionFilter.sevenDays:
      case ConsumptionFilter.thisWeek:
        return _allReadings.length >= 7
            ? _allReadings.sublist(_allReadings.length - 7)
            : _allReadings;
      case ConsumptionFilter.thirtyDays:
      case ConsumptionFilter.thisMonth:
        return _allReadings;
      case ConsumptionFilter.ninetyDays:
        // Scaled replication for 90-day demo display
        return _allReadings;
      case ConsumptionFilter.custom:
        if (_customDateRange == null) return _allReadings;
        final start = _customDateRange!.start;
        final end = _customDateRange!.end.add(const Duration(days: 1));
        return _allReadings.where((r) {
          return r.timestamp.isAfter(start) && r.timestamp.isBefore(end);
        }).toList();
    }
  }

  /// Filtered total consumption
  double get filteredTotalConsumption {
    final readings = filteredReadings;
    return Calculations.calculateTotalConsumption(readings.map((r) => r.energyKwh).toList());
  }

  /// Average daily consumption for active filter
  double get averageDailyConsumption {
    final readings = filteredReadings;
    if (readings.isEmpty) return 0.0;
    return Calculations.calculateAverageConsumption(filteredTotalConsumption, readings.length);
  }

  /// Peak consumption reading in active filter
  double get peakConsumption {
    final readings = filteredReadings;
    if (readings.isEmpty) return 0.0;
    return Calculations.calculatePeakConsumption(readings.map((r) => r.energyKwh).toList());
  }

  /// Lowest consumption reading in active filter
  double get lowestConsumption {
    final readings = filteredReadings;
    if (readings.isEmpty) return 0.0;
    return Calculations.calculateLowestConsumption(readings.map((r) => r.energyKwh).toList());
  }

  /// Estimated electricity bill calculation based on monthly consumption & selected tariff mode
  BillBreakdown get billBreakdown {
    if (_billingRate.isSlabBilling) {
      return Calculations.calculateSlabRateBill(
        consumptionKwh: monthlyConsumption,
        fixedCharge: _billingRate.fixedCharge,
        taxPercent: _billingRate.taxPercent,
      );
    }
    return Calculations.calculateFlatRateBill(
      consumptionKwh: monthlyConsumption,
      ratePerKwh: _billingRate.ratePerKwh,
      fixedCharge: _billingRate.fixedCharge,
      taxPercent: _billingRate.taxPercent,
    );
  }

  /// Total estimated bill value (e.g. ₹1,576)
  double get estimatedBill => billBreakdown.totalBill;

  /// Bill difference compared with last month (e.g. +₹112 or -₹138)
  double get billDifferenceWithLastMonth {
    final lastMonthBill = (_previousMonthConsumption * _billingRate.ratePerKwh) + _billingRate.fixedCharge;
    return estimatedBill - lastMonthBill;
  }

  /// Potential monthly savings aggregated from savings tips (₹286 / month)
  double get potentialMonthlySavings {
    double totalSavings = 0.0;
    for (final tip in _savingsTips) {
      // Dynamic computation: Monthly Consumption * reductionPercentage * Rate
      final dynamicSaving = Calculations.calculatePotentialSavings(
        monthlyKwh: monthlyConsumption,
        reductionPercentage: tip.reductionPercentage,
        ratePerKwh: _billingRate.ratePerKwh,
      );
      totalSavings += dynamicSaving;
    }
    return totalSavings;
  }

  // Actions & Mutations

  Future<void> _initializeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getReadings(),
        _repository.getTodayHourlyReadings(),
        _repository.getAppliances(),
        _repository.getBillingRate(),
        _repository.getSavingsTips(),
      ]);

      _allReadings = results[0] as List<EnergyReading>;
      _todayHourlyReadings = results[1] as List<EnergyReading>;
      _appliances = results[2] as List<Appliance>;
      _billingRate = results[3] as BillingRate;
      _savingsTips = results[4] as List<SavingsTip>;

      _isLoading = false;
      _restartSimulationTimer();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load energy data: $e';
      notifyListeners();
    }
  }

  /// Sets the active consumption filter
  void setFilter(ConsumptionFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  /// Sets a custom date range filter
  void setCustomDateRange(DateTimeRange range) {
    _customDateRange = range;
    _selectedFilter = ConsumptionFilter.custom;
    notifyListeners();
  }

  /// Selects an appliance to inspect
  void selectAppliance(Appliance? appliance) {
    _selectedAppliance = appliance;
    notifyListeners();
  }

  /// Updates billing rate configuration
  void updateBillingRate({
    double? ratePerKwh,
    double? fixedCharge,
    double? additionalCharges,
    double? taxPercent,
    bool? isSlabBilling,
  }) {
    _billingRate = _billingRate.copyWith(
      ratePerKwh: ratePerKwh,
      fixedCharge: fixedCharge,
      additionalCharges: additionalCharges,
      taxPercent: taxPercent,
      isSlabBilling: isSlabBilling,
    );
    notifyListeners();
  }

  /// Toggles between Flat Rate and Slab Rate billing
  void toggleSlabBilling(bool isSlab) {
    _billingRate = _billingRate.copyWith(isSlabBilling: isSlab);
    notifyListeners();
  }

  /// Toggles whether a savings recommendation has been adopted
  void toggleSavingsTipApplied(String tipId) {
    _savingsTips = _savingsTips.map((tip) {
      if (tip.id == tipId) {
        return tip.copyWith(isApplied: !tip.isApplied);
      }
      return tip;
    }).toList();
    notifyListeners();
  }

  /// Changes simulation speed or pauses updates
  void setSimulationSpeed(SimulationSpeed speed) {
    if (_simulationSpeed != speed) {
      _simulationSpeed = speed;
      _restartSimulationTimer();
      notifyListeners();
    }
  }

  /// Switches application theme mode (Light / Dark / System)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Resets demo data back to default presentation state
  Future<void> resetDemoData() async {
    _allReadings = MockEnergyData.getMonthlyReadings();
    _todayHourlyReadings = MockEnergyData.getTodayHourlyReadings();
    _appliances = MockEnergyData.getAppliances();
    _billingRate = MockEnergyData.defaultBillingRate;
    _savingsTips = MockEnergyData.getSavingsTips();
    _selectedFilter = ConsumptionFilter.sevenDays;
    _customDateRange = null;
    _currentPowerKw = 1.84;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Restarts live meter simulation timer according to current speed
  void _restartSimulationTimer() {
    _simulationTimer?.cancel();
    if (_simulationSpeed == SimulationSpeed.paused) return;

    final duration = _simulationSpeed == SimulationSpeed.fast
        ? AppConstants.liveUpdateIntervalFast
        : AppConstants.liveUpdateIntervalNormal;

    _simulationTimer = Timer.periodic(duration, (_) {
      _simulateLivePowerUpdate();
    });
  }

  /// Gradually fluctuates live meter reading within realistic residential limits (1.70 kW to 2.10 kW)
  void _simulateLivePowerUpdate() {
    // Generate gentle realistic random drift (+/- 0.05 to 0.12 kW)
    final delta = (_random.nextDouble() * 0.16) - 0.08;
    double newPower = _currentPowerKw + delta;

    // Clamp within realistic demo range
    if (newPower < 1.70) newPower = 1.72 + (_random.nextDouble() * 0.05);
    if (newPower > 2.15) newPower = 2.10 - (_random.nextDouble() * 0.05);

    _currentPowerKw = double.parse(newPower.toStringAsFixed(2));
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
