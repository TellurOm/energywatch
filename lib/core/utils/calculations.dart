import '../constants/app_constants.dart';

/// Pure, reusable calculation functions for energy consumption, billing, and savings.
/// These functions are decoupled from UI and tested directly.
class Calculations {
  /// Calculates total consumption by summing kWh values.
  static double calculateTotalConsumption(List<double> kwhList) {
    if (kwhList.isEmpty) return 0.0;
    return kwhList.reduce((a, b) => a + b);
  }

  /// Calculates average daily consumption given total consumption and number of days.
  static double calculateAverageConsumption(double totalKwh, int days) {
    if (days <= 0 || totalKwh <= 0) return 0.0;
    return totalKwh / days;
  }

  /// Finds peak (highest) consumption from a list of readings.
  static double calculatePeakConsumption(List<double> kwhList) {
    if (kwhList.isEmpty) return 0.0;
    return kwhList.reduce((curr, next) => curr > next ? curr : next);
  }

  /// Finds lowest consumption from a list of readings.
  static double calculateLowestConsumption(List<double> kwhList) {
    if (kwhList.isEmpty) return 0.0;
    return kwhList.reduce((curr, next) => curr < next ? curr : next);
  }

  /// Calculates percentage change between two values.
  /// Positive value indicates an increase; negative indicates a decrease.
  static double calculatePercentageChange(double current, double previous) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100.0;
  }

  /// Calculates energy consumed by an appliance: Power (kW) * Hours (hr).
  static double calculateApplianceDailyEnergy(double powerKw, double dailyHours) {
    if (powerKw <= 0 || dailyHours <= 0) return 0.0;
    return powerKw * dailyHours;
  }

  /// Calculates percentage share of total household consumption for an appliance.
  static double calculateAppliancePercentage(double applianceKwh, double totalKwh) {
    if (totalKwh <= 0 || applianceKwh <= 0) return 0.0;
    return (applianceKwh / totalKwh) * 100.0;
  }

  /// Calculates flat-rate electricity bill:
  /// Energy Charge = Consumption * Rate
  /// Tax / Surcharge = Energy Charge * (taxPercent / 100)
  /// Total Bill = Energy Charge + Fixed Charge + Tax
  static BillBreakdown calculateFlatRateBill({
    required double consumptionKwh,
    required double ratePerKwh,
    required double fixedCharge,
    double taxPercent = 0.0,
  }) {
    final validConsumption = consumptionKwh < 0 ? 0.0 : consumptionKwh;
    final validRate = ratePerKwh < 0 ? 0.0 : ratePerKwh;
    final validFixed = fixedCharge < 0 ? 0.0 : fixedCharge;

    final energyCharge = validConsumption * validRate;
    final taxCharge = energyCharge * (taxPercent < 0 ? 0.0 : taxPercent / 100.0);
    final totalBill = energyCharge + validFixed + taxCharge;

    return BillBreakdown(
      consumptionKwh: validConsumption,
      energyCharge: energyCharge,
      fixedCharge: validFixed,
      taxCharge: taxCharge,
      totalBill: totalBill,
      isSlabBilling: false,
      slabItems: const [],
    );
  }

  /// Calculates slab-rate (tiered) electricity bill according to standard utility slabs.
  static BillBreakdown calculateSlabRateBill({
    required double consumptionKwh,
    required double fixedCharge,
    List<BillingSlabTier> tiers = AppConstants.slabTiers,
    double taxPercent = 0.0,
  }) {
    final validConsumption = consumptionKwh < 0 ? 0.0 : consumptionKwh;
    final validFixed = fixedCharge < 0 ? 0.0 : fixedCharge;

    double remainingUnits = validConsumption;
    double energyCharge = 0.0;
    final List<SlabCalculationItem> slabItems = [];

    for (final tier in tiers) {
      if (remainingUnits <= 0) break;

      final slabCapacity = tier.maxUnits - tier.minUnits;
      final unitsInThisSlab = remainingUnits > slabCapacity ? slabCapacity : remainingUnits;
      final costForSlab = unitsInThisSlab * tier.ratePerUnit;

      energyCharge += costForSlab;
      remainingUnits -= unitsInThisSlab;

      slabItems.add(SlabCalculationItem(
        label: tier.label,
        units: unitsInThisSlab,
        rate: tier.ratePerUnit,
        cost: costForSlab,
      ));
    }

    final taxCharge = energyCharge * (taxPercent < 0 ? 0.0 : taxPercent / 100.0);
    final totalBill = energyCharge + validFixed + taxCharge;

    return BillBreakdown(
      consumptionKwh: validConsumption,
      energyCharge: energyCharge,
      fixedCharge: validFixed,
      taxCharge: taxCharge,
      totalBill: totalBill,
      isSlabBilling: true,
      slabItems: slabItems,
    );
  }

  /// Calculates potential cost savings for a specific tip or total reduction:
  /// Energy Savings = Monthly Consumption * (reductionPercentage / 100)
  /// Cost Savings = Energy Savings * Rate
  static double calculatePotentialSavings({
    required double monthlyKwh,
    required double reductionPercentage,
    required double ratePerKwh,
  }) {
    if (monthlyKwh <= 0 || reductionPercentage <= 0 || ratePerKwh <= 0) return 0.0;
    final energySavings = monthlyKwh * (reductionPercentage / 100.0);
    return energySavings * ratePerKwh;
  }
}

/// Detailed breakdown of an electricity bill calculation.
class BillBreakdown {
  final double consumptionKwh;
  final double energyCharge;
  final double fixedCharge;
  final double taxCharge;
  final double totalBill;
  final bool isSlabBilling;
  final List<SlabCalculationItem> slabItems;

  const BillBreakdown({
    required this.consumptionKwh,
    required this.energyCharge,
    required this.fixedCharge,
    required this.taxCharge,
    required this.totalBill,
    required this.isSlabBilling,
    required this.slabItems,
  });
}

/// Line-item in a slab breakdown.
class SlabCalculationItem {
  final String label;
  final double units;
  final double rate;
  final double cost;

  const SlabCalculationItem({
    required this.label,
    required this.units,
    required this.rate,
    required this.cost,
  });
}
