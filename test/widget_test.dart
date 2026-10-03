import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:energy_watch/main.dart';
import 'package:energy_watch/providers/energy_provider.dart';

void main() {
  testWidgets('EnergyWatch dashboard renders, navigates, and calculates bill', (WidgetTester tester) async {
    // Configure standard mobile display dimensions
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final energyProvider = EnergyProvider();
    // Pause live simulator timer to ensure deterministic test execution
    energyProvider.setSimulationSpeed(SimulationSpeed.paused);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<EnergyProvider>.value(value: energyProvider),
        ],
        child: const EnergyWatchApp(),
      ),
    );

    // Pump to process asynchronous mock loading
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    // 1. Verify dashboard loads with branding and demo mode badge
    expect(find.text('EnergyWatch'), findsOneWidget);
    expect(find.text('Demo Mode'), findsOneWidget);

    // 2. Verify dashboard summary metrics
    expect(find.text("Today's Consumption"), findsOneWidget);
    expect(find.text('Monthly Consumption'), findsOneWidget);
    expect(find.text('Estimated Bill'), findsOneWidget);
    expect(find.text('Potential Savings'), findsOneWidget);

    // 3. Verify navigation works: tap on 'Consumption'
    await tester.tap(find.text('Consumption'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Consumption History'), findsOneWidget);

    // 4. Verify navigation: tap on 'Appliances' and open details
    await tester.tap(find.text('Appliances'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Track where your energy is going'), findsOneWidget);
    expect(find.text('Air Conditioner'), findsWidgets);

    // Tap on Air Conditioner to open Appliance Details screen
    await tester.tap(find.text('Air Conditioner').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('7-Day Appliance Consumption'), findsOneWidget);
    expect(find.text('Usage Efficiency Score'), findsOneWidget);

    // Navigate back to appliances
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 5. Verify navigation: tap on 'Bill' and test estimator calculation
    await tester.tap(find.text('Bill'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Electricity Bill Estimator'), findsOneWidget);
    expect(find.text('Estimate Bill'), findsOneWidget);

    // Tap the 'Estimate Bill' button
    await tester.tap(find.text('Estimate Bill'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Estimated Electricity Bill'), findsOneWidget);

    // 6. Verify navigation: tap on 'Savings'
    await tester.tap(find.text('Savings'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Save Energy'), findsOneWidget);
    expect(find.text('Potential Monthly Savings'), findsOneWidget);
  });
}
