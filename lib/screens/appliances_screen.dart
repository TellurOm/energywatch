import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/appliance.dart';
import '../providers/energy_provider.dart';
import '../widgets/appliance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import 'appliance_details_screen.dart';

/// Screen listing all household appliances with consumption comparisons and category filtering.
class AppliancesScreen extends StatefulWidget {
  const AppliancesScreen({super.key});

  @override
  State<AppliancesScreen> createState() => _AppliancesScreenState();
}

class _AppliancesScreenState extends State<AppliancesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyProvider>();

    if (energy.isLoading) {
      return Scaffold(body: EmptyStateWidget.loading());
    }

    final appliances = energy.appliances;
    final totalApplianceKwh = appliances.fold<double>(0.0, (sum, a) => sum + a.monthlyKwh);

    // Extract categories
    final categories = ['All', ...{...appliances.map((a) => a.category)}];

    // Filter by category and search query
    final filteredAppliances = appliances.where((app) {
      final matchesCategory = _selectedCategory == 'All' || app.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SectionHeader(
                title: 'Appliances',
                subtitle: 'Track where your energy is going',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 14),

              // Summary Banner
              _buildSummaryHeaderCard(context, appliances.length, totalApplianceKwh),
              const SizedBox(height: 20),

              // Top Consumers Comparison Section (Section 13)
              _buildComparisonSection(context, appliances),
              const SizedBox(height: 24),

              // Search & Filter Bar
              _buildSearchAndFilters(context, categories),
              const SizedBox(height: 16),

              // Appliance Cards Grid / List
              if (filteredAppliances.isEmpty)
                EmptyStateWidget(
                  title: 'No appliances found',
                  message: 'Try changing your search term or category filter.',
                  icon: Icons.search_off_rounded,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isGrid = constraints.maxWidth >= 720;

                    if (isGrid) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 220,
                        ),
                        itemCount: filteredAppliances.length,
                        itemBuilder: (context, index) {
                          final app = filteredAppliances[index];
                          return ApplianceCard(
                            appliance: app,
                            onTap: () => _openDetails(context, app),
                          );
                        },
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAppliances.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = filteredAppliances[index];
                        return ApplianceCard(
                          appliance: app,
                          onTap: () => _openDetails(context, app),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, Appliance app) {
    context.read<EnergyProvider>().selectAppliance(app);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplianceDetailsScreen(appliance: app),
      ),
    );
  }

  Widget _buildSummaryHeaderCard(BuildContext context, int count, double totalKwh) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [AppColors.primaryContainer.withValues(alpha: 0.7), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count Tracked Appliances',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${Formatters.formatEnergy(totalKwh, decimals: 1)} this month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              '100% Calibrated',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(BuildContext context, List<Appliance> appliances) {
    final theme = Theme.of(context);
    final sorted = List<Appliance>.from(appliances)..sort((a, b) => b.percentage.compareTo(a.percentage));
    final topItems = sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Highest Consumption',
              subtitle: 'Relative share of total home energy',
              padding: EdgeInsets.zero,
            ),
            const Divider(height: 24),
            ...topItems.map((item) {
              Color barColor = AppColors.primary;
              if (item.percentage >= 30) {
                barColor = AppColors.alert;
              } else if (item.percentage >= 15) {
                barColor = AppColors.warning;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: () => _openDetails(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(item.iconData, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  item.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${item.percentage.toStringAsFixed(0)}% (${Formatters.formatEnergy(item.monthlyKwh, decimals: 1)})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.percentage / 100.0,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceContainer,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
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

  Widget _buildSearchAndFilters(BuildContext context, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search appliance by name or category...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
