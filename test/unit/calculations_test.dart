import 'package:flutter_test/flutter_test.dart';
import 'package:energy_watch/core/utils/calculations.dart';

void main() {
  group('Consumption Calculations', () {
    test('calculateTotalConsumption sums a list of kWh readings', () {
      final readings = [5.8, 6.2, 7.1, 6.5, 8.0, 7.4, 6.72];
      final total = Calculations.calculateTotalConsumption(readings);
      expect(total, closeTo(47.72, 0.001));
    });

    test('calculateTotalConsumption handles empty lists safely', () {
      expect(Calculations.calculateTotalConsumption([]), 0.0);
    });

    test('calculateAverageConsumption computes correct daily average', () {
      final average = Calculations.calculateAverageConsumption(184.5, 30);
      expect(average, closeTo(6.15, 0.01));
    });

    test('calculatePeakConsumption returns the maximum reading', () {
      final readings = [5.8, 6.2, 7.1, 6.5, 8.4, 7.4, 4.7];
      expect(Calculations.calculatePeakConsumption(readings), 8.4);
    });

    test('calculateLowestConsumption returns the minimum reading', () {
      final readings = [5.8, 6.2, 7.1, 6.5, 8.4, 7.4, 4.7];
      expect(Calculations.calculateLowestConsumption(readings), 4.7);
    });

    test('calculatePercentageChange computes trend correctly', () {
      // 6.72 vs 7.10 -> -5.35%
      final change = Calculations.calculatePercentageChange(6.72, 7.10);
      expect(change, closeTo(-5.35, 0.05));
    });
  });

  group('Bill Calculations', () {
    test('calculateFlatRateBill computes energy charge and fixed charge accurately', () {
      // 184.5 kWh @ ₹8.00 + ₹100 fixed = ₹1,576
      final bill = Calculations.calculateFlatRateBill(
        consumptionKwh: 184.5,
        ratePerKwh: 8.00,
        fixedCharge: 100.0,
      );

      expect(bill.energyCharge, closeTo(1476.0, 0.01));
      expect(bill.fixedCharge, 100.0);
      expect(bill.totalBill, closeTo(1576.0, 0.01));
      expect(bill.isSlabBilling, false);
    });

    test('calculateFlatRateBill applies tax percentage when specified', () {
      final bill = Calculations.calculateFlatRateBill(
        consumptionKwh: 100.0,
        ratePerKwh: 8.00,
        fixedCharge: 50.0,
        taxPercent: 5.0, // 5% of 800 = 40
      );

      expect(bill.energyCharge, 800.0);
      expect(bill.taxCharge, 40.0);
      expect(bill.totalBill, 890.0);
    });

    test('calculateSlabRateBill calculates progressive tiers', () {
      // Tier 1: 0–100 @ ₹4.50 = ₹450
      // Tier 2: 101–200 (84.5 units) @ ₹6.00 = ₹507
      // Total energy charge = 450 + 507 = 957
      // Fixed charge = ₹100
      // Total = ₹1,057
      final bill = Calculations.calculateSlabRateBill(
        consumptionKwh: 184.5,
        fixedCharge: 100.0,
      );

      expect(bill.isSlabBilling, true);
      expect(bill.energyCharge, closeTo(957.0, 0.01));
      expect(bill.totalBill, closeTo(1057.0, 0.01));
      expect(bill.slabItems.length, 2);
    });

    test('calculateSlabRateBill handles consumption exceeding 300 units', () {
      // 350 units:
      // 100 @ 4.5 = 450
      // 100 @ 6.0 = 600
      // 100 @ 8.0 = 800
      // 50 @ 10.0 = 500
      // Energy = 2350 + 100 fixed = 2450
      final bill = Calculations.calculateSlabRateBill(
        consumptionKwh: 350.0,
        fixedCharge: 100.0,
      );

      expect(bill.energyCharge, closeTo(2350.0, 0.01));
      expect(bill.totalBill, closeTo(2450.0, 0.01));
      expect(bill.slabItems.length, 4);
    });
  });

  group('Appliance Calculations', () {
    test('calculateApplianceDailyEnergy computes kW * hours', () {
      // 1.5 kW * 5.2 hours = 7.8 kWh
      final energy = Calculations.calculateApplianceDailyEnergy(1.5, 5.2);
      expect(energy, closeTo(7.8, 0.01));
    });

    test('calculateAppliancePercentage computes correct percentage share', () {
      // 72.4 kWh out of 184.5 kWh = ~39.2%
      final percent = Calculations.calculateAppliancePercentage(72.4, 184.5);
      expect(percent, closeTo(39.24, 0.1));
    });
  });

  group('Savings Calculations', () {
    test('calculatePotentialSavings computes cost reduction from reduction %', () {
      // 184.5 kWh * 6.5% = 11.99 kWh * ₹8.00 = ₹95.94 (~₹96)
      final savings = Calculations.calculatePotentialSavings(
        monthlyKwh: 184.5,
        reductionPercentage: 6.5,
        ratePerKwh: 8.0,
      );
      expect(savings, closeTo(95.94, 0.1));
    });
  });
}
