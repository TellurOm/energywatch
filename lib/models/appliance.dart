import 'package:flutter/material.dart';

/// Represents an electrical appliance tracked by EnergyWatch.
class Appliance {
  final String id;
  final String name;
  final IconData iconData;
  final double powerKw;
  final double dailyHours;
  final double monthlyKwh;
  final bool isActive;
  final String category;
  final double percentage; // Percentage of total consumption
  final double estimatedMonthlyCost;
  final DateTime lastActive;
  final List<double> weeklyKwh; // 7 days of consumption for the details chart
  final int efficiencyScore; // Efficiency rating out of 100
  final String recommendation;

  const Appliance({
    required this.id,
    required this.name,
    required this.iconData,
    required this.powerKw,
    required this.dailyHours,
    required this.monthlyKwh,
    required this.isActive,
    required this.category,
    required this.percentage,
    required this.estimatedMonthlyCost,
    required this.lastActive,
    required this.weeklyKwh,
    required this.efficiencyScore,
    required this.recommendation,
  });

  /// Today's consumption derived from power and daily usage
  double get todayKwh => weeklyKwh.isNotEmpty ? weeklyKwh.last : (powerKw * dailyHours);

  Appliance copyWith({
    String? id,
    String? name,
    IconData? iconData,
    double? powerKw,
    double? dailyHours,
    double? monthlyKwh,
    bool? isActive,
    String? category,
    double? percentage,
    double? estimatedMonthlyCost,
    DateTime? lastActive,
    List<double>? weeklyKwh,
    int? efficiencyScore,
    String? recommendation,
  }) {
    return Appliance(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      powerKw: powerKw ?? this.powerKw,
      dailyHours: dailyHours ?? this.dailyHours,
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      percentage: percentage ?? this.percentage,
      estimatedMonthlyCost: estimatedMonthlyCost ?? this.estimatedMonthlyCost,
      lastActive: lastActive ?? this.lastActive,
      weeklyKwh: weeklyKwh ?? this.weeklyKwh,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
