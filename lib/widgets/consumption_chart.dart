import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/energy_reading.dart';
import '../providers/energy_provider.dart';

/// Interactive Line & Area Chart for visualizing energy consumption trends.
class ConsumptionChart extends StatelessWidget {
  final List<EnergyReading> readings;
  final ConsumptionFilter currentFilter;
  final ValueChanged<ConsumptionFilter>? onFilterChanged;
  final bool showFilterTabs;
  final double height;

  const ConsumptionChart({
    super.key,
    required this.readings,
    this.currentFilter = ConsumptionFilter.sevenDays,
    this.onFilterChanged,
    this.showFilterTabs = true,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (readings.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No consumption data available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxY = 0.0;

    for (int i = 0; i < readings.length; i++) {
      final val = readings[i].energyKwh;
      if (val > maxY) maxY = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    // Add 15% top margin for chart clarity
    maxY = (maxY * 1.15).clamp(1.0, 100.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showFilterTabs) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consumption Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _buildRangeSelector(context),
                ],
              ),
              const SizedBox(height: 18),
            ],
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 20 ? 10 : 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY > 20 ? 10 : 2,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value > maxY) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: _calculateInterval(readings.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= readings.length) {
                            return const SizedBox.shrink();
                          }
                          final date = readings[index].timestamp;
                          final label = readings.length <= 7
                              ? Formatters.formatDayOfWeek(date)
                              : '${date.day}/${date.month}';

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (readings.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.primaryLight,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: readings.length <= 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: AppColors.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryLight.withValues(alpha: 0.35),
                            AppColors.primaryLight.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => isDark ? AppColors.darkSurfaceVariant : Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final date = readings[index].timestamp;
                          return LineTooltipItem(
                            '${Formatters.formatDayMonth(date)}\n',
                            const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: '${spot.y.toStringAsFixed(2)} kWh',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
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

  double _calculateInterval(int length) {
    if (length <= 7) return 1.0;
    if (length <= 14) return 2.0;
    if (length <= 31) return 5.0;
    return 10.0;
  }

  Widget _buildRangeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      (ConsumptionFilter.sevenDays, '7D'),
      (ConsumptionFilter.thirtyDays, '30D'),
      (ConsumptionFilter.ninetyDays, '90D'),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = currentFilter == opt.$1;
          return InkWell(
            onTap: () => onFilterChanged?.call(opt.$1),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opt.$2,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Hourly Bar Chart specifically for showing 24-hour profiles with peak hour highlights.
class HourlyConsumptionBarChart extends StatelessWidget {
  final List<EnergyReading> hourlyReadings;
  final double height;

  const HourlyConsumptionBarChart({
    super.key,
    required this.hourlyReadings,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (hourlyReadings.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No hourly readings recorded.')),
      );
    }

    final barGroups = <BarChartGroupData>[];
    double maxKwh = 0.0;

    for (int i = 0; i < hourlyReadings.length; i++) {
      final reading = hourlyReadings[i];
      if (reading.energyKwh > maxKwh) maxKwh = reading.energyKwh;

      final isPeak = reading.isPeakHour;
      final barColor = isPeak ? AppColors.warning : AppColors.primary;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: reading.energyKwh,
              color: barColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    maxKwh = (maxKwh * 1.2).clamp(1.0, 50.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Hourly Consumption Pattern',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Peak Hours (6–10 PM)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: BarChart(
                BarChartData(
                  maxY: maxKwh,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, _) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            val.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx < 0 || idx >= hourlyReadings.length) {
                            return const SizedBox.shrink();
                          }
                          // Show titles for alternating items to avoid crowding
                          if (idx % 2 != 0) return const SizedBox.shrink();
                          final hour = hourlyReadings[idx].timestamp.hour;
                          final label = hour == 0
                              ? '12 AM'
                              : (hour < 12 ? '$hour AM' : (hour == 12 ? '12 PM' : '${hour - 12} PM'));

                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => isDark ? AppColors.darkSurfaceVariant : Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final reading = hourlyReadings[group.x];
                        final timeStr = Formatters.formatTime(reading.timestamp);
                        return BarTooltipItem(
                          '$timeStr\n',
                          const TextStyle(color: Colors.white70, fontSize: 11),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(2)} kWh',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (reading.isPeakHour)
                              const TextSpan(
                                text: ' (Peak)',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        );
                      },
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
}
