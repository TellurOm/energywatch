import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated linear progress bar with contextual color scaling based on energy consumption share.
class UsageProgressBar extends StatelessWidget {
  final double percentage; // e.g. 39.0
  final double height;
  final bool showLabel;
  final String? customLabel;

  const UsageProgressBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.showLabel = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedPercent = (percentage / 100.0).clamp(0.0, 1.0);

    // Color scaling
    Color barColor;
    if (percentage >= 30.0) {
      barColor = AppColors.alert;
    } else if (percentage >= 15.0) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customLabel ?? 'Share of total consumption',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Semantics(
          label: 'Energy consumption share ${percentage.toStringAsFixed(1)} percent',
          value: '${percentage.toStringAsFixed(1)}%',
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clampedPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
