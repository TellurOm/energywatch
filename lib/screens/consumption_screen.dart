import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../providers/energy_provider.dart';
import '../widgets/consumption_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

/// Dedicated consumption analytics screen supporting multi-period filtering,
/// statistical aggregations, and hourly peak pattern visualization.
class ConsumptionScreen extends StatelessWidget {
  final VoidCallback? onNavigateToAppliances;

  const ConsumptionScreen({
    super.key,
    this.onNavigateToAppliances,
  });

  Future<void> _pickCustomDateRange(BuildContext context, EnergyProvider energy) async {
    final now = DateTime.now();
    final initialRange = energy.customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 14)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      helpText: 'Select Custom Date Range',
      cancelText: 'Cancel',
      confirmText: 'Apply',
    );

    if (picked != null) {
      energy.setCustomDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energy = context.watch<EnergyProvider>();

    if (energy.isLoading) {
      return Scaffold(body: EmptyStateWidget.loading());
    }

    final filteredReadings = energy.filteredReadings;

    String filterTitle;
    switch (energy.selectedFilter) {
      case ConsumptionFilter.today:
        filterTitle = 'Today';
        break;
      case ConsumptionFilter.thisWeek:
      case ConsumptionFilter.sevenDays:
        filterTitle = 'This Week (7 Days)';
        break;
      case ConsumptionFilter.thisMonth:
      case ConsumptionFilter.thirtyDays:
        filterTitle = 'This Month (30 Days)';
        break;
      case ConsumptionFilter.ninetyDays:
        filterTitle = 'Last 90 Days';
        break;
      case ConsumptionFilter.custom:
        if (energy.customDateRange != null) {
          filterTitle =
              '${Formatters.formatDayMonth(energy.customDateRange!.start)} – ${Formatters.formatDayMonth(energy.customDateRange!.end)}';
        } else {
          filterTitle = 'Custom Range';
        }
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Heading
                  SectionHeader(
                    title: 'Consumption History',
                    subtitle: 'Detailed electricity analytics & pattern discovery',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips Bar
                  _buildFilterBar(context, energy),
                  const SizedBox(height: 18),

                  // Metric Stat Cards (Total, Average, Peak, Lowest)
                  _buildStatsRow(context, energy, filterTitle, isWide: isWide),
                  const SizedBox(height: 20),

                  // Period Comparison Banner
                  _buildComparisonBanner(context, energy),
                  const SizedBox(height: 20),

                  // Chart 1: Daily Trend
                  SectionHeader(
                    title: 'Consumption Trend ($filterTitle)',
                    subtitle: 'Day-to-day aggregate meter readings',
                  ),
                  const SizedBox(height: 8),
                  ConsumptionChart(
                    readings: filteredReadings,
                    currentFilter: energy.selectedFilter,
                    showFilterTabs: false,
                    height: 250,
                  ),
                  const SizedBox(height: 24),

                  // Chart 2: Hourly Profile with Peak Highlight
                  SectionHeader(
                    title: '24-Hour Load Profile',
                    subtitle: 'Identify high-demand hours and standby intervals',
                  ),
                  const SizedBox(height: 8),
                  HourlyConsumptionBarChart(
                    hourlyReadings: energy.todayHourlyReadings,
                    height: 220,
                  ),
                  const SizedBox(height: 20),

                  // Appliance shortcut card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.pie_chart_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appliance Breakdown',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'See which appliances consumed the most energy during this period.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onNavigateToAppliances != null)
                            FilledButton.tonal(
                              onPressed: onNavigateToAppliances,
                              child: const Text('Inspect'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, EnergyProvider energy) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            context,
            label: 'Today',
            selected: energy.selectedFilter == ConsumptionFilter.today,
            onSelected: () => energy.setFilter(ConsumptionFilter.today),
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: 'This Week',
            selected: energy.selectedFilter == ConsumptionFilter.sevenDays ||
                energy.selectedFilter == ConsumptionFilter.thisWeek,
            onSelected: () => energy.setFilter(ConsumptionFilter.sevenDays),
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: 'This Month',
            selected: energy.selectedFilter == ConsumptionFilter.thirtyDays ||
                energy.selectedFilter == ConsumptionFilter.thisMonth,
            onSelected: () => energy.setFilter(ConsumptionFilter.thirtyDays),
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: '90 Days',
            selected: energy.selectedFilter == ConsumptionFilter.ninetyDays,
            onSelected: () => energy.setFilter(ConsumptionFilter.ninetyDays),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range_rounded, size: 16),
                const SizedBox(width: 6),
                Text(
                  energy.selectedFilter == ConsumptionFilter.custom && energy.customDateRange != null
                      ? '${Formatters.formatDayMonth(energy.customDateRange!.start)} - ${Formatters.formatDayMonth(energy.customDateRange!.end)}'
                      : 'Custom',
                ),
              ],
            ),
            selected: energy.selectedFilter == ConsumptionFilter.custom,
            onSelected: (_) => _pickCustomDateRange(context, energy),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    EnergyProvider energy,
    String filterTitle, {
    required bool isWide,
  }) {
    final stats = [
      StatCard(
        title: 'Total Consumption',
        value: Formatters.formatEnergy(energy.filteredTotalConsumption, decimals: 1),
        subtitle: filterTitle,
        icon: Icons.electric_bolt_rounded,
      ),
      StatCard(
        title: 'Average Daily',
        value: '${energy.averageDailyConsumption.toStringAsFixed(2)} kWh/day',
        subtitle: 'Average per 24 hours',
        icon: Icons.speed_rounded,
      ),
      StatCard(
        title: 'Peak Usage',
        value: Formatters.formatEnergy(energy.peakConsumption),
        subtitle: 'Highest single reading',
        icon: Icons.vertical_align_top_rounded,
        iconColor: AppColors.alert,
      ),
      StatCard(
        title: 'Lowest Usage',
        value: Formatters.formatEnergy(energy.lowestConsumption),
        subtitle: 'Base standby demand',
        icon: Icons.vertical_align_bottom_rounded,
        iconColor: AppColors.success,
      ),
    ];

    if (isWide) {
      return Row(
        children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: s))).toList(),
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: stats[0]),
              const SizedBox(width: 8),
              Expanded(child: stats[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: stats[2]),
              const SizedBox(width: 8),
              Expanded(child: stats[3]),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildComparisonBanner(BuildContext context, EnergyProvider energy) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPositive = energy.weekChangePercent < 0;
    final bannerColor = isPositive ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: bannerColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isPositive
                  ? 'Great progress! Consumption is ${energy.weekChangePercent.abs().toStringAsFixed(1)}% below the previous reference period.'
                  : 'Notice: Consumption is ${energy.weekChangePercent.abs().toStringAsFixed(1)}% higher than the previous period.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
