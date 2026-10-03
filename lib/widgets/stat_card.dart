import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable metric statistic card for dashboard and summary views.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final double? trendPercent;
  final String? trendLabel;
  final bool isTrendGoodWhenNegative; // Lower energy is good (green)
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.trendPercent,
    this.trendLabel,
    this.isTrendGoodWhenNegative = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryIconColor = iconColor ?? theme.colorScheme.primary;
    final primaryIconBg = iconBgColor ??
        (isDark ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : AppColors.primaryContainer);

    Color trendColor = theme.colorScheme.onSurfaceVariant;
    IconData? trendIcon;

    if (trendPercent != null) {
      final isNegative = trendPercent! < 0;
      final isFavorable = isTrendGoodWhenNegative ? isNegative : !isNegative;

      trendColor = isFavorable ? AppColors.success : AppColors.alert;
      trendIcon = isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryIconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primaryIconColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              if (trendPercent != null || trendLabel != null) ...[
                Row(
                  children: [
                    if (trendIcon != null) ...[
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(
                        trendLabel ??
                            '${trendPercent!.abs().toStringAsFixed(1)}% vs previous',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
