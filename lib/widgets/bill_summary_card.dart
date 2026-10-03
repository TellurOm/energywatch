import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/calculations.dart';
import '../core/utils/formatters.dart';

/// Card showing the calculated bill breakdown, last-month comparison, and projected consumption.
class BillSummaryCard extends StatelessWidget {
  final BillBreakdown breakdown;
  final double differenceWithLastMonth;
  final double projectedMonthlyKwh;
  final VoidCallback? onDetailsTap;

  const BillSummaryCard({
    super.key,
    required this.breakdown,
    required this.differenceWithLastMonth,
    required this.projectedMonthlyKwh,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isHigher = differenceWithLastMonth > 0;
    final diffColor = isHigher ? AppColors.alert : AppColors.success;
    final diffIcon = isHigher ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final diffText = isHigher
        ? '${Formatters.formatCurrency(differenceWithLastMonth.abs())} higher than last month'
        : '${Formatters.formatCurrency(differenceWithLastMonth.abs())} lower than last month';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Estimated Electricity Bill',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    breakdown.isSlabBilling ? 'Slab Tariff' : 'Flat Tariff',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Big Total Hero Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  Formatters.formatCurrency(breakdown.totalBill),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'for ${breakdown.consumptionKwh.toStringAsFixed(1)} kWh',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Comparison Pill
            Row(
              children: [
                Icon(diffIcon, size: 16, color: diffColor),
                const SizedBox(width: 4),
                Text(
                  diffText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: diffColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Line items
            _buildLineItem(
              context,
              label: 'Energy Charge',
              value: Formatters.formatCurrency(breakdown.energyCharge, showDecimals: true),
            ),
            const SizedBox(height: 8),
            _buildLineItem(
              context,
              label: 'Fixed Meter Charge',
              value: Formatters.formatCurrency(breakdown.fixedCharge, showDecimals: true),
            ),
            if (breakdown.taxCharge > 0) ...[
              const SizedBox(height: 8),
              _buildLineItem(
                context,
                label: 'Electricity Duty / Taxes',
                value: Formatters.formatCurrency(breakdown.taxCharge, showDecimals: true),
              ),
            ],
            const Divider(height: 28),

            // Projected consumption notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Projected Monthly Total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${projectedMonthlyKwh.toStringAsFixed(1)} kWh (~${Formatters.formatCurrency((projectedMonthlyKwh * 8.0) + 100)})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDetailsTap != null)
                    OutlinedButton(
                      onPressed: onDetailsTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Breakdown', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
