import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/savings_tip.dart';
import '../providers/energy_provider.dart';
import '../widgets/savings_tip_card.dart';
import '../widgets/section_header.dart';

/// Screen presenting actionable energy-saving recommendations with dynamic savings calculations
/// based on monthly consumption and tariff rate.
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  void _showTipStepsDialog(BuildContext context, SavingsTip tip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(tip.iconData, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(tip.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Potential Saving: ${Formatters.formatCurrency(tip.estimatedSaving)} / month (-${tip.reductionPercentage}%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommended Steps:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              tip.actionSteps,
              style: const TextStyle(height: 1.5),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyProvider>();

    final tips = energy.savingsTips;
    final totalSavings = energy.potentialMonthlySavings;
    final appliedCount = tips.where((t) => t.isApplied).length;

    // Derived environmental metrics
    final totalKwhSaved = (energy.monthlyConsumption * 0.194); // ~19.4% total potential reduction
    final co2SavedKg = totalKwhSaved * 0.82; // ~0.82 kg CO2 per kWh grid average

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SectionHeader(
                title: 'Save Energy',
                subtitle: 'Simple changes can reduce your bill and environmental impact',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Hero Savings Card
              _buildSavingsHeroCard(
                context,
                totalSavings: totalSavings,
                totalKwhSaved: totalKwhSaved,
                co2SavedKg: co2SavedKg,
                appliedCount: appliedCount,
                totalTips: tips.length,
              ),
              const SizedBox(height: 24),

              // Recommendations Section Title
              SectionHeader(
                title: 'Personalized Recommendations',
                subtitle: 'Ranked by highest cost-reduction impact',
              ),
              const SizedBox(height: 8),

              // Tip Cards Grid / List
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  if (isWide) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 215,
                      ),
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        final tip = tips[index];
                        return SavingsTipCard(
                          tip: tip,
                          onApplyToggle: () => energy.toggleSavingsTipApplied(tip.id),
                          onViewSteps: () => _showTipStepsDialog(context, tip),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tips.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tip = tips[index];
                      return SavingsTipCard(
                        tip: tip,
                        onApplyToggle: () => energy.toggleSavingsTipApplied(tip.id),
                        onViewSteps: () => _showTipStepsDialog(context, tip),
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

  Widget _buildSavingsHeroCard(
    BuildContext context, {
    required double totalSavings,
    required double totalKwhSaved,
    required double co2SavedKg,
    required int appliedCount,
    required int totalTips,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF0F766E)]
              : [const Color(0xFF047857), const Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Potential Monthly Savings',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$appliedCount of $totalTips Applied',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            Formatters.formatCurrency(totalSavings),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Calculated dynamically from monthly usage (184.5 kWh @ ₹8/unit)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImpactItem(
                  context,
                  label: 'Energy Conserved',
                  value: '~${totalKwhSaved.toStringAsFixed(1)} kWh/mo',
                  icon: Icons.electric_bolt_rounded,
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildImpactItem(
                  context,
                  label: 'Carbon Offset',
                  value: '~${co2SavedKg.toStringAsFixed(1)} kg CO₂',
                  icon: Icons.cloud_done_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
