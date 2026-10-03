import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../providers/energy_provider.dart';
import '../widgets/consumption_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/energy_summary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/usage_progress.dart';
import 'appliance_details_screen.dart';

/// Presentation-ready dashboard displaying live energy status, key metrics, charts,
/// and appliance highlights.
class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToConsumption;
  final VoidCallback? onNavigateToAppliances;
  final VoidCallback? onNavigateToBill;
  final VoidCallback? onNavigateToSavings;

  const DashboardScreen({
    super.key,
    this.onNavigateToConsumption,
    this.onNavigateToAppliances,
    this.onNavigateToBill,
    this.onNavigateToSavings,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyProvider>();

    if (energy.isLoading) {
      return Scaffold(body: EmptyStateWidget.loading());
    }

    if (energy.errorMessage != null) {
      return Scaffold(
        body: EmptyStateWidget.error(
          message: energy.errorMessage,
          onRetry: () => energy.resetDemoData(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isMedium = constraints.maxWidth >= 600 && !isWide;

        return RefreshIndicator(
          onRefresh: () async => energy.resetDemoData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    _buildGreetingHeader(context),
                    const SizedBox(height: 16),

                    // Weekly Status Banner
                    EnergyStatusBanner(
                      reductionPercent: energy.weekChangePercent.abs(),
                      onDetailsTap: onNavigateToConsumption,
                    ),
                    const SizedBox(height: 16),

                    // Top Key Stat Cards
                    _buildStatGrid(context, energy, isWide: isWide, isMedium: isMedium),
                    const SizedBox(height: 16),

                    // Current Live Load Card
                    LiveCurrentLoadCard(
                      currentPowerKw: energy.currentPowerKw,
                      lastUpdated: energy.lastUpdated,
                      onInfoTap: () => _showLiveLoadExplanation(context),
                    ),
                    const SizedBox(height: 20),

                    // Chart Section with Range Filter
                    ConsumptionChart(
                      readings: energy.getFilteredReadingsForFilter(energy.selectedFilter),
                      currentFilter: energy.selectedFilter,
                      onFilterChanged: (filter) => energy.setFilter(filter),
                    ),
                    const SizedBox(height: 12),

                    // View Full Consumption CTA Button
                    Center(
                      child: TextButton.icon(
                        onPressed: onNavigateToConsumption,
                        icon: const Icon(Icons.analytics_outlined, size: 18),
                        label: const Text('View Detailed Consumption Analytics'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Responsive 2-column container for Recent Consumption + Top Appliances
                    if (isWide || isMedium)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTodayUsageTimeline(context, energy)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTopAppliancesCard(context, energy)),
                        ],
                      )
                    else ...[
                      _buildTodayUsageTimeline(context, energy),
                      const SizedBox(height: 18),
                      _buildTopAppliancesCard(context, energy),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${AppConstants.defaultUser} 👋',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s your energy overview for today',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(
    BuildContext context,
    EnergyProvider energy, {
    required bool isWide,
    required bool isMedium,
  }) {
    final cards = [
      StatCard(
        title: 'Today\'s Consumption',
        value: Formatters.formatEnergy(energy.todayConsumption),
        icon: Icons.today_rounded,
        trendPercent: energy.todayChangePercent,
        trendLabel: '↓ ${energy.todayChangePercent.abs().toStringAsFixed(1)}% vs yesterday',
        isTrendGoodWhenNegative: true,
        onTap: onNavigateToConsumption,
      ),
      StatCard(
        title: 'Monthly Consumption',
        value: Formatters.formatEnergy(energy.monthlyConsumption, decimals: 1),
        icon: Icons.calendar_month_rounded,
        trendPercent: -8.5,
        trendLabel: '↓ 8.5% vs last month',
        isTrendGoodWhenNegative: true,
        onTap: onNavigateToConsumption,
      ),
      StatCard(
        title: 'Estimated Bill',
        value: Formatters.formatCurrency(energy.estimatedBill),
        icon: Icons.receipt_rounded,
        subtitle: 'At ₹8.00/unit base tariff',
        onTap: onNavigateToBill,
      ),
      StatCard(
        title: 'Potential Savings',
        value: '${Formatters.formatCurrency(energy.potentialMonthlySavings)} / month',
        icon: Icons.savings_rounded,
        iconColor: AppColors.success,
        iconBgColor: AppColors.successBg,
        subtitle: 'From 6 conservation steps',
        onTap: onNavigateToSavings,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: c))).toList(),
      );
    } else if (isMedium) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 8),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 8),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 8),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 8),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTodayUsageTimeline(BuildContext context, EnergyProvider energy) {
    final theme = Theme.of(context);
    final readings = energy.todayHourlyReadings;

    // Filter to key checkpoint intervals matching Section 10
    final checkpoints = readings.where((r) => r.timestamp.hour >= 8 && r.timestamp.hour <= 20).toList();
    final displayList = checkpoints.isNotEmpty ? checkpoints : readings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Today\'s Usage Timeline',
              subtitle: 'Meter intervals throughout the day',
              padding: EdgeInsets.zero,
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = displayList[index];
                final isPeak = item.isPeakHour;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPeak ? Icons.wb_twilight_rounded : Icons.schedule_rounded,
                            size: 16,
                            color: isPeak ? AppColors.warning : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              Formatters.formatTime(item.timestamp),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPeak) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Peak',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.formatEnergy(item.energyKwh),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppliancesCard(BuildContext context, EnergyProvider energy) {
    final theme = Theme.of(context);
    final topAppliances = energy.appliances.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Top Energy Consumers',
              subtitle: 'Largest contributors this month',
              trailing: TextButton(
                onPressed: onNavigateToAppliances,
                child: const Text('View All'),
              ),
              padding: EdgeInsets.zero,
            ),
            const Divider(height: 24),
            ...topAppliances.map((app) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: InkWell(
                  onTap: () {
                    energy.selectAppliance(app);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ApplianceDetailsScreen(appliance: app),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(app.iconData, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                app.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${app.percentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: app.percentage >= 30 ? AppColors.alert : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        UsageProgressBar(percentage: app.percentage, height: 6),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLiveLoadExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Active Power Measurement'),
        content: const Text(
          'Active Power (kW) represents the instantaneous electricity demand of active home appliances. '
          'In this prototype, readings fluctuate realistically between 1.70 kW and 2.15 kW. '
          'When connected to an IoT smart meter (such as an ESP32 ADE7758/PZEM-004T), this card displays real hardware sensor data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
