import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/energy_provider.dart';
import '../widgets/section_header.dart';

/// Application configuration screen for data sources, simulation speed,
/// tariff parameters, theme mode, and architecture overview.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetConfirmDialog(BuildContext context, EnergyProvider energy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Demo Data?'),
        content: const Text(
          'This will restore all readings, appliances, billing rates, and conservation tips '
          'to their original presentation values (184.5 kWh monthly total, ₹1,576 estimated bill).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              energy.resetDemoData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo presentation data restored successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('About Demo Mode'),
          ],
        ),
        content: const Text(
          AppConstants.demoDisclaimer,
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energy = context.watch<EnergyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data Source Section (Section 24)
                SectionHeader(
                  title: 'Data Source',
                  subtitle: 'Select between simulated meter readings and external hardware APIs',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.sensors_rounded, color: AppColors.primary),
                        title: Text('Demo Data (Simulated Meter)', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Calibrated residential consumption profile'),
                        trailing: Icon(Icons.check_circle_rounded, color: AppColors.primary),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.cloud_off_rounded, color: Colors.grey),
                        title: Row(
                          children: [
                            const Text('Smart Meter API / IoT Device', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Coming Soon',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Direct integration with ESP32, Modbus, or MQTT broker',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Simulation Speed Controls (Section 24)
                SectionHeader(
                  title: 'Demo Simulation Speed',
                  subtitle: 'Control how quickly real-time active power values drift during presentation',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<SimulationSpeed>(
                          segments: const [
                            ButtonSegment(
                              value: SimulationSpeed.normal,
                              label: Text('Normal (6s)'),
                              icon: Icon(Icons.play_arrow_rounded),
                            ),
                            ButtonSegment(
                              value: SimulationSpeed.fast,
                              label: Text('Fast (2s)'),
                              icon: Icon(Icons.fast_forward_rounded),
                            ),
                            ButtonSegment(
                              value: SimulationSpeed.paused,
                              label: Text('Paused'),
                              icon: Icon(Icons.pause_rounded),
                            ),
                          ],
                          selected: {energy.simulationSpeed},
                          onSelectionChanged: (selected) {
                            energy.setSimulationSpeed(selected.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Current Active Load: ${energy.currentPowerKw.toStringAsFixed(2)} kW • Status: ${energy.simulationSpeed == SimulationSpeed.paused ? "Paused" : "Active"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance & Theme Section
                SectionHeader(
                  title: 'Appearance',
                  subtitle: 'Choose between Light and Dark interface themes',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light Mode'),
                              icon: Icon(Icons.light_mode_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark Mode'),
                              icon: Icon(Icons.dark_mode_rounded),
                            ),
                          ],
                          selected: {energy.themeMode},
                          onSelectionChanged: (selected) {
                            energy.setThemeMode(selected.first);
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          energy.themeMode == ThemeMode.light
                              ? 'Light Theme: Clean white & emerald palette'
                              : 'Dark Theme: High contrast deep navy & slate palette',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Hardware Architecture Documentation Card (Section 41)
                SectionHeader(
                  title: 'Hardware & IoT Architecture',
                  subtitle: 'How EnergyWatch connects to physical sensors in production',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hardware Integration Pipeline',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'EnergyWatch implements the Repository pattern with abstract EnergyDataSource:\n\n'
                          '1. Hardware Layer: ESP32 + CT sensor (SCT-013) / PZEM-004T measures RMS voltage & current.\n'
                          '2. Transport Layer: Publishes MQTT payloads / JSON via REST API.\n'
                          '3. Flutter Layer: ApiEnergyDataSource implements EnergyDataSource interface without modifying any UI or provider logic.',
                          style: TextStyle(height: 1.5, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reset & Information Actions (Section 29)
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        title: const Text('About Demo Data'),
                        subtitle: const Text('Read simulation notes for presentation'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showAboutDemoDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore_rounded, color: AppColors.alert),
                        title: const Text('Reset Demo Data', style: TextStyle(color: AppColors.alert)),
                        subtitle: const Text('Restore calibrated 184.5 kWh dataset'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showResetConfirmDialog(context, energy),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
