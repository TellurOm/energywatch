import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/savings_tip.dart';

/// Reusable card displaying an energy conservation recommendation.
class SavingsTipCard extends StatelessWidget {
  final SavingsTip tip;
  final VoidCallback? onApplyToggle;
  final VoidCallback? onViewSteps;

  const SavingsTipCard({
    super.key,
    required this.tip,
    this.onApplyToggle,
    this.onViewSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color diffBadgeColor;
    if (tip.difficulty == 'Easy') {
      diffBadgeColor = AppColors.success;
    } else if (tip.difficulty == 'Medium') {
      diffBadgeColor = AppColors.warning;
    } else {
      diffBadgeColor = AppColors.alert;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: tip.isApplied
              ? Border.all(color: AppColors.success, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Category + Difficulty Chip
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tip.iconData,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.category.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        tip.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: diffBadgeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tip.difficulty,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: diffBadgeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              tip.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // Savings Hero Tag & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Savings',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          Formatters.formatCurrency(tip.estimatedSaving),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          '/month',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${tip.reductionPercentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onViewSteps != null)
                      TextButton.icon(
                        onPressed: onViewSteps,
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text('Steps', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    if (onApplyToggle != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: onApplyToggle,
                        icon: Icon(
                          tip.isApplied ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                          color: tip.isApplied ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: tip.isApplied ? 'Applied' : 'Mark as done',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
