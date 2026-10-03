import 'package:flutter/material.dart';
import '../models/energy_reading.dart';
import '../models/appliance.dart';
import '../models/billing_rate.dart';
import '../models/savings_tip.dart';

/// Coherent, realistic mock data for EnergyWatch college prototype.
/// All metrics are synchronized:
/// - Monthly consumption: 184.5 kWh
/// - Previous month: 201.7 kWh
/// - Today: 6.72 kWh (yesterday: 7.10 kWh, -5.35%)
/// - Base bill: 184.5 * 8 = ₹1,476 + ₹100 fixed = ₹1,576
/// - Total savings tips: ₹286 / month
class MockEnergyData {
  /// Base electricity billing tariff
  static const BillingRate defaultBillingRate = BillingRate(
    ratePerKwh: 8.00,
    fixedCharge: 100.00,
    additionalCharges: 0.00,
    taxPercent: 0.0, // Base bill exactly ₹1,576
    isSlabBilling: false,
  );

  /// 30-day historical daily readings (generating 184.5 kWh total)
  static List<EnergyReading> getMonthlyReadings() {
    final now = DateTime.now();
    // Daily values over the last 30 days
    // Last 7 days match the problem statement prompt exactly:
    // Monday: 5.8, Tuesday: 6.2, Wednesday: 7.1, Thursday: 6.5, Friday: 8.0, Saturday: 7.4, Sunday: 6.72
    final dailyKwhList = [
      5.9, 6.1, 6.3, 5.7, 6.4, 6.8, 6.2, // Days 30-24
      5.5, 6.0, 6.2, 5.8, 6.5, 6.9, 6.1, // Days 23-17
      5.6, 6.3, 6.7, 5.9, 6.2, 7.0, 6.4, // Days 16-10
      7.10, // Day 9 (Yesterday reference 7.10)
      5.4, 5.9, // Days 8-7
      5.8, 6.2, 7.1, 6.5, 8.0, 7.4, 6.72, // Days 6-0 (Recent 7 days ending with today's 6.72)
    ];

    final List<EnergyReading> readings = [];
    for (int i = 0; i < dailyKwhList.length; i++) {
      final daysAgo = dailyKwhList.length - 1 - i;
      final date = now.subtract(Duration(days: daysAgo));
      final kwh = dailyKwhList[i];
      // Instantaneous power load in kW roughly correlated with daily load
      final powerKw = (kwh / 24.0) * (1.8 + (i % 3) * 0.2);

      readings.add(EnergyReading(
        timestamp: DateTime(date.year, date.month, date.day, 20, 0),
        powerKw: double.parse(powerKw.toStringAsFixed(2)),
        energyKwh: kwh,
        source: 'Demo Meter',
      ));
    }
    return readings;
  }

  /// Today's detailed hourly readings (from 12 AM to 10 PM)
  static List<EnergyReading> getTodayHourlyReadings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final hourlyData = [
      (0, 0.35, 0.42),  // 12 AM
      (2, 0.29, 0.36),  // 02 AM
      (4, 0.24, 0.32),  // 04 AM
      (6, 0.48, 0.65),  // 06 AM
      (8, 0.82, 1.25),  // 08 AM
      (10, 1.10, 1.48), // 10 AM
      (12, 1.46, 1.82), // 12 PM
      (14, 1.02, 1.35), // 02 PM
      (16, 0.88, 1.15), // 04 PM
      (18, 1.44, 2.10), // 06 PM (Peak)
      (20, 1.51, 2.25), // 08 PM (Peak)
      (22, 0.94, 1.30), // 10 PM
    ];

    return hourlyData.map((item) {
      return EnergyReading(
        timestamp: today.add(Duration(hours: item.$1)),
        energyKwh: item.$2,
        powerKw: item.$3,
        source: 'Demo Meter',
      );
    }).toList();
  }

  /// 10 realistic household appliances with power ratings, consumption, and recommendations
  static List<Appliance> getAppliances() {
    final now = DateTime.now();

    return [
      Appliance(
        id: 'app_ac',
        name: 'Air Conditioner',
        iconData: Icons.ac_unit_rounded,
        powerKw: 1.50,
        dailyHours: 5.2,
        monthlyKwh: 72.4,
        isActive: true,
        category: 'Cooling',
        percentage: 39.0,
        estimatedMonthlyCost: 579.0, // 72.4 * 8.0
        lastActive: now.subtract(const Duration(minutes: 5)),
        weeklyKwh: [5.1, 4.8, 6.2, 5.5, 7.1, 6.0, 5.2],
        efficiencyScore: 72,
        recommendation:
            'Your AC accounts for 39% of household consumption. Increasing the thermostat by 1–2°C and cleaning filters monthly may save up to ₹96/month.',
      ),
      Appliance(
        id: 'app_water_heater',
        name: 'Water Heater',
        iconData: Icons.water_drop_rounded,
        powerKw: 2.00,
        dailyHours: 0.65,
        monthlyKwh: 38.7,
        isActive: false,
        category: 'Heating',
        percentage: 21.0,
        estimatedMonthlyCost: 310.0, // 38.7 * 8.0
        lastActive: now.subtract(const Duration(hours: 4)),
        weeklyKwh: [2.8, 2.7, 3.1, 2.9, 3.5, 3.2, 2.8],
        efficiencyScore: 68,
        recommendation:
            'Water heating is your 2nd largest consumer. Reduce geyser runtime to 15 minutes before baths and lower thermostat from 65°C to 50°C.',
      ),
      Appliance(
        id: 'app_refrigerator',
        name: 'Refrigerator',
        iconData: Icons.kitchen_rounded,
        powerKw: 0.18,
        dailyHours: 24.0,
        monthlyKwh: 25.8,
        isActive: true,
        category: 'Kitchen',
        percentage: 14.0,
        estimatedMonthlyCost: 206.0, // 25.8 * 8.0
        lastActive: now.subtract(const Duration(minutes: 1)),
        weeklyKwh: [1.8, 1.9, 1.8, 1.9, 1.9, 1.8, 1.8],
        efficiencyScore: 85,
        recommendation:
            'Ensure adequate 10cm rear ventilation behind condenser coils and avoid keeping warm leftovers inside to maintain optimal efficiency.',
      ),
      Appliance(
        id: 'app_washing_machine',
        name: 'Washing Machine',
        iconData: Icons.local_laundry_service_rounded,
        powerKw: 0.85,
        dailyHours: 0.50,
        monthlyKwh: 12.9,
        isActive: false,
        category: 'Laundry',
        percentage: 7.0,
        estimatedMonthlyCost: 103.0,
        lastActive: now.subtract(const Duration(hours: 18)),
        weeklyKwh: [0.9, 0.0, 1.0, 0.0, 1.2, 1.8, 0.9],
        efficiencyScore: 78,
        recommendation:
            'Run washing cycles with full capacity and choose 30°C eco-wash modes rather than hot water cycles to save energy.',
      ),
      Appliance(
        id: 'app_television',
        name: 'Smart Television',
        iconData: Icons.tv_rounded,
        powerKw: 0.12,
        dailyHours: 4.5,
        monthlyKwh: 9.2,
        isActive: true,
        category: 'Entertainment',
        percentage: 5.0,
        estimatedMonthlyCost: 74.0,
        lastActive: now.subtract(const Duration(minutes: 12)),
        weeklyKwh: [0.7, 0.6, 0.8, 0.6, 0.9, 0.9, 0.7],
        efficiencyScore: 80,
        recommendation:
            'Disable instant-on standby mode and enable automatic ambient light sensor dimming to prevent excessive backlight draw.',
      ),
      Appliance(
        id: 'app_desktop',
        name: 'Desktop Computer',
        iconData: Icons.computer_rounded,
        powerKw: 0.22,
        dailyHours: 4.0,
        monthlyKwh: 7.4,
        isActive: true,
        category: 'Work/Study',
        percentage: 4.0,
        estimatedMonthlyCost: 59.0,
        lastActive: now.subtract(const Duration(minutes: 2)),
        weeklyKwh: [0.6, 0.6, 0.6, 0.6, 0.7, 0.4, 0.5],
        efficiencyScore: 76,
        recommendation:
            'Configure display sleep after 5 minutes and system sleep after 15 minutes of inactivity to cut idle workstation drain.',
      ),
      Appliance(
        id: 'app_fans',
        name: 'Ceiling Fans (3x)',
        iconData: Icons.mode_fan_off_rounded,
        powerKw: 0.09,
        dailyHours: 14.0,
        monthlyKwh: 7.4,
        isActive: true,
        category: 'Cooling',
        percentage: 4.0,
        estimatedMonthlyCost: 59.0,
        lastActive: now.subtract(const Duration(minutes: 5)),
        weeklyKwh: [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6],
        efficiencyScore: 92,
        recommendation:
            'Fans cool occupants through evaporative airflow, not room air temperature. Switch off fans when vacating rooms.',
      ),
      Appliance(
        id: 'app_lights',
        name: 'LED Smart Lighting',
        iconData: Icons.lightbulb_rounded,
        powerKw: 0.11,
        dailyHours: 5.0,
        monthlyKwh: 5.5,
        isActive: true,
        category: 'Lighting',
        percentage: 3.0,
        estimatedMonthlyCost: 44.0,
        lastActive: now.subtract(const Duration(minutes: 10)),
        weeklyKwh: [0.4, 0.4, 0.4, 0.4, 0.5, 0.4, 0.4],
        efficiencyScore: 90,
        recommendation:
            'Modern LED fixtures are already highly efficient. Utilize sunset/sunrise automated schedules to avoid accidental daytime use.',
      ),
      Appliance(
        id: 'app_microwave',
        name: 'Microwave Oven',
        iconData: Icons.microwave_rounded,
        powerKw: 1.20,
        dailyHours: 0.15,
        monthlyKwh: 3.7,
        isActive: false,
        category: 'Kitchen',
        percentage: 2.0,
        estimatedMonthlyCost: 30.0,
        lastActive: now.subtract(const Duration(hours: 6)),
        weeklyKwh: [0.3, 0.2, 0.3, 0.2, 0.4, 0.3, 0.3],
        efficiencyScore: 75,
        recommendation:
            'Use lids to trap steam and speed up heating times. Switch off main outlet when not in use to eliminate 3W display standby load.',
      ),
      Appliance(
        id: 'app_water_pump',
        name: 'Water Pump',
        iconData: Icons.water_rounded,
        powerKw: 0.75,
        dailyHours: 0.16,
        monthlyKwh: 3.5,
        isActive: false,
        category: 'Utility',
        percentage: 2.0,
        estimatedMonthlyCost: 28.0,
        lastActive: now.subtract(const Duration(hours: 9)),
        weeklyKwh: [0.3, 0.2, 0.3, 0.3, 0.3, 0.3, 0.3],
        efficiencyScore: 82,
        recommendation:
            'Inspect pipeline joints for micro-leaks. Schedule water tank filling in afternoon hours to avoid grid peak surcharge rates.',
      ),
    ];
  }

  /// Curated energy savings tips with percentage reduction and estimated savings
  /// Total savings = 96 + 71 + 42 + 38 + 24 + 15 = ₹286/month
  static List<SavingsTip> getSavingsTips() {
    return const [
      SavingsTip(
        id: 'tip_ac',
        title: 'AC Temperature Optimization',
        description: 'Raise AC thermostat by 1–2°C and clean the filters regularly.',
        estimatedSaving: 96.0,
        reductionPercentage: 6.5,
        difficulty: 'Medium',
        category: 'Cooling',
        iconData: Icons.thermostat_rounded,
        actionSteps:
            '1. Set your AC thermostat to 24°C - 26°C instead of 18°C.\n2. Clean the air filter mesh every 2-3 weeks.\n3. Keep curtains drawn during sunny afternoon hours.',
      ),
      SavingsTip(
        id: 'tip_geyser',
        title: 'Water Heater Scheduling',
        description: 'Reduce geyser heating duration and lower thermostat to 50°C.',
        estimatedSaving: 71.0,
        reductionPercentage: 4.8,
        difficulty: 'Easy',
        category: 'Heating',
        iconData: Icons.hot_tub_rounded,
        actionSteps:
            '1. Turn on the water heater only 15 minutes before bathing.\n2. Turn off immediately after use or install a mechanical timer.\n3. Lower water thermostat dial from 65°C to 50°C.',
      ),
      SavingsTip(
        id: 'tip_standby',
        title: 'Eliminate Standby Vampire Load',
        description: 'Switch off TVs, desktop computers, and chargers at the wall switch.',
        estimatedSaving: 42.0,
        reductionPercentage: 2.8,
        difficulty: 'Easy',
        category: 'Standby',
        iconData: Icons.power_off_rounded,
        actionSteps:
            '1. Use a power strip with a master switch for entertainment units.\n2. Unplug phone and laptop chargers when fully charged.\n3. Turn off set-top boxes and gaming consoles when idle.',
      ),
      SavingsTip(
        id: 'tip_lighting',
        title: 'Lighting Upgrade & Scheduling',
        description: 'Ensure 100% LED bulbs and leverage natural daylight during daytime.',
        estimatedSaving: 38.0,
        reductionPercentage: 2.5,
        difficulty: 'Easy',
        category: 'Lighting',
        iconData: Icons.lightbulb_outline_rounded,
        actionSteps:
            '1. Replace any remaining CFL or incandescent bulbs with 9W LEDs.\n2. Keep light fixtures and glass covers clean for maximum lumen output.\n3. Utilize natural window daylight during morning hours.',
      ),
      SavingsTip(
        id: 'tip_fridge',
        title: 'Refrigerator Maintenance',
        description: 'Inspect magnetic door gasket seals and keep cooling dial at 3°C to 4°C.',
        estimatedSaving: 24.0,
        reductionPercentage: 1.6,
        difficulty: 'Easy',
        category: 'Kitchen',
        iconData: Icons.kitchen_rounded,
        actionSteps:
            '1. Test door seal by closing a paper currency note in the door; it should feel snug.\n2. Allow hot foods to cool to room temperature before placing in the fridge.\n3. Keep 10 cm space behind the fridge for coil ventilation.',
      ),
      SavingsTip(
        id: 'tip_peak_shifting',
        title: 'Peak Load Shifting',
        description: 'Run washing machines and water pumps during off-peak morning hours.',
        estimatedSaving: 15.0,
        reductionPercentage: 1.0,
        difficulty: 'Medium',
        category: 'Utility',
        iconData: Icons.schedule_rounded,
        actionSteps:
            '1. Avoid operating high-wattage appliances between 6:00 PM and 10:00 PM.\n2. Run washing machine laundry loads on weekend mornings.\n3. Fill overhead water storage tanks during mid-day.',
      ),
    ];
  }
}
