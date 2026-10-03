import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/calculations.dart';
import '../core/utils/formatters.dart';
import '../providers/energy_provider.dart';
import '../widgets/bill_summary_card.dart';
import '../widgets/section_header.dart';

/// Interactive bill estimation screen with Material form validation,
/// flat vs slab tariff toggle, dynamic calculations, and detailed breakdown dialog.
class BillEstimatorScreen extends StatefulWidget {
  const BillEstimatorScreen({super.key});

  @override
  State<BillEstimatorScreen> createState() => _BillEstimatorScreenState();
}

class _BillEstimatorScreenState extends State<BillEstimatorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _consumptionController;
  late TextEditingController _rateController;
  late TextEditingController _fixedChargeController;
  late TextEditingController _taxPercentController;

  bool _isSlabRate = false;
  BillBreakdown? _calculatedBreakdown;

  @override
  void initState() {
    super.initState();
    final energy = context.read<EnergyProvider>();

    _consumptionController = TextEditingController(
      text: energy.monthlyConsumption.toStringAsFixed(1),
    );
    _rateController = TextEditingController(
      text: energy.billingRate.ratePerKwh.toStringAsFixed(2),
    );
    _fixedChargeController = TextEditingController(
      text: energy.billingRate.fixedCharge.toStringAsFixed(0),
    );
    _taxPercentController = TextEditingController(
      text: energy.billingRate.taxPercent.toStringAsFixed(0),
    );

    _isSlabRate = energy.billingRate.isSlabBilling;
    _runCalculation();
  }

  @override
  void dispose() {
    _consumptionController.dispose();
    _rateController.dispose();
    _fixedChargeController.dispose();
    _taxPercentController.dispose();
    super.dispose();
  }

  void _runCalculation() {
    final consumption = double.tryParse(_consumptionController.text) ?? 184.5;
    final rate = double.tryParse(_rateController.text) ?? 8.0;
    final fixed = double.tryParse(_fixedChargeController.text) ?? 100.0;
    final tax = double.tryParse(_taxPercentController.text) ?? 0.0;

    setState(() {
      if (_isSlabRate) {
        _calculatedBreakdown = Calculations.calculateSlabRateBill(
          consumptionKwh: consumption,
          fixedCharge: fixed,
          taxPercent: tax,
        );
      } else {
        _calculatedBreakdown = Calculations.calculateFlatRateBill(
          consumptionKwh: consumption,
          ratePerKwh: rate,
          fixedCharge: fixed,
          taxPercent: tax,
        );
      }
    });
  }

  void _onEstimatePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _runCalculation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bill updated: ${Formatters.formatCurrency(_calculatedBreakdown?.totalBill ?? 0)}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBreakdownDialog(BuildContext context, BillBreakdown breakdown) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Detailed Bill Computation'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tariff Structure: ${breakdown.isSlabBilling ? 'Progressive Slab Rate' : 'Flat Single Rate'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (breakdown.isSlabBilling && breakdown.slabItems.isNotEmpty) ...[
                const Text('Slab breakdown:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                ...breakdown.slabItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.label} (${item.units.toStringAsFixed(1)} units @ ₹${item.rate})',
                            style: const TextStyle(fontSize: 12)),
                        Text(Formatters.formatCurrency(item.cost, showDecimals: true),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
                const Divider(),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Energy Charge:'),
                  Text(Formatters.formatCurrency(breakdown.energyCharge, showDecimals: true)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fixed Meter Charge:'),
                  Text(Formatters.formatCurrency(breakdown.fixedCharge, showDecimals: true)),
                ],
              ),
              if (breakdown.taxCharge > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Electricity Duty & Tax:'),
                    Text(Formatters.formatCurrency(breakdown.taxCharge, showDecimals: true)),
                  ],
                ),
              ],
              const Divider(thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Estimated Bill:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    Formatters.formatCurrency(breakdown.totalBill),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final energy = context.watch<EnergyProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SectionHeader(
                title: 'Electricity Bill Estimator',
                subtitle: 'Accurately forecast utility costs with flat or tiered tariff structures',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 18),

              // Tariff Mode Toggle (Flat vs Slab)
              _buildTariffModeToggle(context),
              const SizedBox(height: 18),

              // Form Container
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing Parameters',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Monthly Consumption field
                        TextFormField(
                          controller: _consumptionController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Monthly Consumption (kWh)',
                            hintText: 'e.g. 184.5 or 200',
                            prefixIcon: const Icon(Icons.flash_on_rounded),
                            suffixText: 'kWh',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.restore_rounded, size: 20),
                              tooltip: 'Use current month actual (184.5 kWh)',
                              onPressed: () {
                                _consumptionController.text = energy.monthlyConsumption.toStringAsFixed(1);
                                _runCalculation();
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a valid consumption value.';
                            }
                            final num = double.tryParse(val.trim());
                            if (num == null) {
                              return 'Please enter a valid numeric value.';
                            }
                            if (num < 0) {
                              return 'Consumption cannot be negative.';
                            }
                            if (num > 5000) {
                              return 'Value is unusually high for residential use.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Electricity Rate (only for Flat Rate)
                        if (!_isSlabRate) ...[
                          TextFormField(
                            controller: _rateController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Electricity Rate (₹/kWh)',
                              hintText: 'e.g. 8.00',
                              prefixIcon: Icon(Icons.currency_rupee_rounded),
                              suffixText: '₹/kWh',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter an electricity rate.';
                              }
                              final num = double.tryParse(val.trim());
                              if (num == null) {
                                return 'Please enter a valid rate number.';
                              }
                              if (num < 0) {
                                return 'Rate cannot be negative.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ] else ...[
                          _buildSlabInfoCard(context),
                          const SizedBox(height: 14),
                        ],

                        // Row: Fixed Charge & Tax
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fixedChargeController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Fixed Charge (₹)',
                                  hintText: '100',
                                  prefixIcon: Icon(Icons.receipt_long_rounded),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Fixed charge required.';
                                  }
                                  final num = double.tryParse(val.trim());
                                  if (num == null) {
                                    return 'Invalid number.';
                                  }
                                  if (num < 0) {
                                    return 'Cannot be negative.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _taxPercentController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Tax / Duty (%)',
                                  hintText: '0',
                                  prefixIcon: Icon(Icons.percent_rounded),
                                ),
                                validator: (val) {
                                  if (val != null && val.isNotEmpty) {
                                    final num = double.tryParse(val.trim());
                                    if (num == null || num < 0) {
                                      return 'Invalid tax.';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _onEstimatePressed,
                            icon: const Icon(Icons.calculate_rounded),
                            label: const Text('Estimate Bill'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Card with Calculations & Comparison
              if (_calculatedBreakdown != null) ...[
                BillSummaryCard(
                  breakdown: _calculatedBreakdown!,
                  differenceWithLastMonth: energy.billDifferenceWithLastMonth,
                  projectedMonthlyKwh: energy.projectedMonthlyConsumption,
                  onDetailsTap: () => _showBreakdownDialog(context, _calculatedBreakdown!),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTariffModeToggle(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          label: Text('Flat Rate Tariff'),
          icon: Icon(Icons.straighten_rounded),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text('Slab Rate Tariff'),
          icon: Icon(Icons.stairs_rounded),
        ),
      ],
      selected: {_isSlabRate},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() {
          _isSlabRate = newSelection.first;
          _runCalculation();
        });
      },
    );
  }

  Widget _buildSlabInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Active Utility Slabs',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...AppConstants.slabTiers.map((tier) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tier.label, style: theme.textTheme.bodySmall),
                  Text(
                    '₹${tier.ratePerUnit.toStringAsFixed(2)} / unit',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
