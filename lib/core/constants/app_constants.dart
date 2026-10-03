/// Application-wide constants for EnergyWatch.
class AppConstants {
  static const String appName = 'EnergyWatch';
  static const String appTagline = 'Smart energy insights for your home';
  static const String defaultUser = 'Amitabh';

  // Demo & Simulation
  static const String dataSourceDemo = 'Demo Data (Simulated Meter)';
  static const String dataSourceReal = 'Smart Meter API';
  static const Duration liveUpdateIntervalNormal = Duration(seconds: 6);
  static const Duration liveUpdateIntervalFast = Duration(seconds: 2);

  // Default Billing Constants
  static const double defaultRatePerKwh = 8.00; // ₹8.00 / kWh
  static const double defaultFixedCharge = 100.00; // ₹100 fixed
  static const double defaultAdditionalTaxPercent = 5.0; // 5% tax

  // Slab Billing Tiers (Units / kWh, Rate / unit)
  static const List<BillingSlabTier> slabTiers = [
    BillingSlabTier(minUnits: 0, maxUnits: 100, ratePerUnit: 4.50, label: '0–100 units'),
    BillingSlabTier(minUnits: 100, maxUnits: 200, ratePerUnit: 6.00, label: '101–200 units'),
    BillingSlabTier(minUnits: 200, maxUnits: 300, ratePerUnit: 8.00, label: '201–300 units'),
    BillingSlabTier(minUnits: 300, maxUnits: double.infinity, ratePerUnit: 10.00, label: '300+ units'),
  ];

  // Disclaimers
  static const String demoDisclaimer =
      'EnergyWatch is currently running with simulated energy readings for demonstration. '
      'The application architecture can later be connected to a smart meter, IoT sensor, or energy-provider API without rewriting the UI.';
}

/// Representation of a single electricity billing tier/slab.
class BillingSlabTier {
  final double minUnits;
  final double maxUnits;
  final double ratePerUnit;
  final String label;

  const BillingSlabTier({
    required this.minUnits,
    required this.maxUnits,
    required this.ratePerUnit,
    required this.label,
  });
}
