import '../models/energy_reading.dart';
import '../models/appliance.dart';
import '../models/billing_rate.dart';
import '../models/savings_tip.dart';
import 'mock_energy_data.dart';

/// Abstract contract for energy data sources.
/// In production, this can be swapped with ApiEnergyDataSource, MqttEnergyDataSource,
/// or FirebaseEnergyDataSource without changing repository or UI layers.
abstract class EnergyDataSource {
  Future<List<EnergyReading>> getReadings();
  Future<List<EnergyReading>> getTodayHourlyReadings();
  Future<List<Appliance>> getAppliances();
  Future<BillingRate> getBillingRate();
  Future<List<SavingsTip>> getSavingsTips();
}

/// Simulated mock implementation of [EnergyDataSource].
/// Delivers realistic mock data for college presentation & demo mode.
class MockEnergyDataSource implements EnergyDataSource {
  @override
  Future<List<EnergyReading>> getReadings() async {
    // Simulate brief network latency for realism
    await Future.delayed(const Duration(milliseconds: 150));
    return MockEnergyData.getMonthlyReadings();
  }

  @override
  Future<List<EnergyReading>> getTodayHourlyReadings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockEnergyData.getTodayHourlyReadings();
  }

  @override
  Future<List<Appliance>> getAppliances() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockEnergyData.getAppliances();
  }

  @override
  Future<BillingRate> getBillingRate() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockEnergyData.defaultBillingRate;
  }

  @override
  Future<List<SavingsTip>> getSavingsTips() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockEnergyData.getSavingsTips();
  }
}
