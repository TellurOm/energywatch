import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/calculations.dart';
import '../core/utils/formatters.dart';
import '../models/appliance.dart';
import '../providers/energy_provider.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

/// Detailed view for an individual appliance featuring 7-day bar chart,
/// efficiency score, data-driven recommendation, and interactive runtime calculator.
class ApplianceDetailsScreen extends StatefulWidget {
  final Appliance appliance;

  const ApplianceDetailsScreen({super.key, required this.appliance});

  @override
  State<ApplianceDetailsScreen> createState() => _ApplianceDetailsScreenState();
}

class _ApplianceDetailsScreenState extends State<ApplianceDetailsScreen> {
  late double _simulatedDailyHours;

  @override
  void initState() {
    super.initState();
    _simulatedDailyHours = widget.appliance.dailyHours;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energy = context.watch<EnergyProvider>();
    final app = widget.appliance;

    // Interactive simulator calculations
    final simulatedDailyKwh = Calculations.calculateApplianceDailyEnergy(app.powerKw, _simulatedDailyHours);
    final simulatedMonthlyKwh = simulatedDailyKwh * 30.0;
    final simulatedMonthlyCost = simulatedMonthlyKwh * energy.billingRate.ratePerKwh;
    final costDifference = simulatedMonthlyCost - app.estimatedMonthlyCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: app.isActive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: app.isActive ? AppColors.success : AppColors.lightTextMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  app.isActive ? 'Active' : 'Standby',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: app.isActive ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Card
                _buildHeroCard(context, app),
                const SizedBox(height: 18),

                // Key 4-metric grid
                _buildMetricsGrid(context, app),
                const SizedBox(height: 20),

                // 7-day Usage Bar Chart (Section 12)
                _buildWeeklyUsageChart(context, app),
                const SizedBox(height: 20),

                // Efficiency Score Card (Section 12)
                _buildEfficiencyCard(context, app),
                const SizedBox(height: 20),

                // Dynamic Recommendation (Section 12)
                _buildRecommendationCard(context, app),
                const SizedBox(height: 20),

                // Interactive Runtime Adjuster / Simulator
                _buildRuntimeSimulatorCard(
                  context,
                  app: app,
                  simulatedDailyKwh: simulatedDailyKwh,
                  simulatedMonthlyCost: simulatedMonthlyCost,
                  costDifference: costDifference,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Appliance app) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(app.iconData, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${app.category} • Last active ${Formatters.formatTimeAgo(app.lastActive)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${app.percentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'of Total',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Appliance app) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Current Power',
                value: Formatters.formatPower(app.powerKw),
                icon: Icons.flash_on_rounded,
                subtitle: 'Rated load',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                title: 'Today\'s Usage',
                value: Formatters.formatEnergy(app.todayKwh),
                icon: Icons.today_rounded,
                subtitle: '${app.dailyHours.toStringAsFixed(1)} hours runtime',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Monthly Usage',
                value: Formatters.formatEnergy(app.monthlyKwh, decimals: 1),
                icon: Icons.calendar_month_rounded,
                subtitle: '30-day recorded total',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                title: 'Monthly Cost',
                value: Formatters.formatCurrency(app.estimatedMonthlyCost),
                icon: Icons.receipt_rounded,
                subtitle: 'At ₹8.00 / kWh',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyUsageChart(BuildContext context, Appliance app) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = app.weeklyKwh;

    double maxVal = 0.0;
    for (final v in data) {
      if (v > maxVal) maxVal = v;
    }
    maxVal = (maxVal * 1.25).clamp(1.0, 50.0);

    final bars = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i],
              color: AppColors.primaryLight,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: '7-Day Appliance Consumption',
              subtitle: 'Daily historical usage breakdown',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxVal,
                  barGroups: bars,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) {
                          if (v == 0) return const SizedBox.shrink();
                          return Text(
                            v.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                days[idx],
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard(BuildContext context, Appliance app) {
    final theme = Theme.of(context);
    final score = app.efficiencyScore;

    Color scoreColor;
    String scoreStatus;
    if (score >= 85) {
      scoreColor = AppColors.success;
      scoreStatus = 'Excellent Efficiency';
    } else if (score >= 70) {
      scoreColor = AppColors.primary;
      scoreStatus = 'Good Efficiency';
    } else if (score >= 50) {
      scoreColor = AppColors.warning;
      scoreStatus = 'Moderate (Optimization Needed)';
    } else {
      scoreColor = AppColors.alert;
      scoreStatus = 'Poor Efficiency';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 6,
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Text(
                  '$score%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Efficiency Score',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scoreStatus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calculated based on runtime ratio vs standby duty cycles.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Appliance app) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : AppColors.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Action',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.recommendation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuntimeSimulatorCard(
    BuildContext context, {
    required Appliance app,
    required double simulatedDailyKwh,
    required double simulatedMonthlyCost,
    required double costDifference,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Runtime Adjustment Simulator',
              subtitle: 'Drag slider to simulate how adjusting runtime impacts your bill',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Simulated Runtime',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_simulatedDailyHours.toStringAsFixed(1)} hr/day',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _simulatedDailyHours,
              min: 0.0,
              max: app.category == 'Kitchen' && app.name.contains('Refrigerator') ? 24.0 : 16.0,
              divisions: 32,
              label: '${_simulatedDailyHours.toStringAsFixed(1)} hr',
              onChanged: (val) {
                setState(() {
                  _simulatedDailyHours = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        Formatters.formatEnergy(simulatedDailyKwh),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('Daily Usage', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        Formatters.formatCurrency(simulatedMonthlyCost),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('Simulated Bill', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        costDifference <= 0
                            ? 'Save ${Formatters.formatCurrency(costDifference.abs())}'
                            : '+${Formatters.formatCurrency(costDifference)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: costDifference <= 0 ? AppColors.success : AppColors.alert,
                        ),
                      ),
                      Text('Net Impact', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
