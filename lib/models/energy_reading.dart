/// Represents an energy reading from an electric meter (simulated or hardware).
class EnergyReading {
  final DateTime timestamp;
  final double powerKw;
  final double energyKwh;
  final String source;

  const EnergyReading({
    required this.timestamp,
    required this.powerKw,
    required this.energyKwh,
    this.source = 'Demo Meter',
  });

  /// True if the reading occurred during peak residential tariff hours (18:00 - 22:00).
  bool get isPeakHour {
    final hour = timestamp.hour;
    return hour >= 18 && hour < 22;
  }

  EnergyReading copyWith({
    DateTime? timestamp,
    double? powerKw,
    double? energyKwh,
    String? source,
  }) {
    return EnergyReading(
      timestamp: timestamp ?? this.timestamp,
      powerKw: powerKw ?? this.powerKw,
      energyKwh: energyKwh ?? this.energyKwh,
      source: source ?? this.source,
    );
  }
}
