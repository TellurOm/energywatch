import 'package:flutter/material.dart';

/// Represents an actionable energy savings recommendation.
class SavingsTip {
  final String id;
  final String title;
  final String description;
  final double estimatedSaving; // Dynamic or estimated monthly savings in ₹
  final double reductionPercentage; // Percentage of monthly bill this can reduce
  final String difficulty; // "Easy", "Medium", "Hard"
  final String category;
  final IconData iconData;
  final bool isApplied;
  final String actionSteps;

  const SavingsTip({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedSaving,
    required this.reductionPercentage,
    required this.difficulty,
    required this.category,
    required this.iconData,
    this.isApplied = false,
    required this.actionSteps,
  });

  SavingsTip copyWith({
    String? id,
    String? title,
    String? description,
    double? estimatedSaving,
    double? reductionPercentage,
    String? difficulty,
    String? category,
    IconData? iconData,
    bool? isApplied,
    String? actionSteps,
  }) {
    return SavingsTip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedSaving: estimatedSaving ?? this.estimatedSaving,
      reductionPercentage: reductionPercentage ?? this.reductionPercentage,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      iconData: iconData ?? this.iconData,
      isApplied: isApplied ?? this.isApplied,
      actionSteps: actionSteps ?? this.actionSteps,
    );
  }
}
