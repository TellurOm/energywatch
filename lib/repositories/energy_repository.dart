import '../data/mock_data_source.dart';
import '../models/energy_reading.dart';
import '../models/appliance.dart';
import '../models/billing_rate.dart';
import '../models/savings_tip.dart';

/// Repository that acts as the single source of truth for energy data.
/// Mediates between the data sources (Mock, API, MQTT, BLE) and the application state.
class EnergyRepository {
  final EnergyDataSource _dataSource;

  EnergyRepository({EnergyDataSource? dataSource})
      : _dataSource = dataSource ?? MockEnergyDataSource();

  /// Retrieves historical daily readings (30 days)
  Future<List<EnergyReading>> getReadings() async {
    return await _dataSource.getReadings();
  }

  /// Retrieves today's 24-hour reading profile
  Future<List<EnergyReading>> getTodayHourlyReadings() async {
    return await _dataSource.getTodayHourlyReadings();
  }

  /// Retrieves tracked household appliances
  Future<List<Appliance>> getAppliances() async {
    return await _dataSource.getAppliances();
  }

  /// Retrieves current electricity billing rate configuration
  Future<BillingRate> getBillingRate() async {
    return await _dataSource.getBillingRate();
  }

  /// Retrieves curated conservation tips
  Future<List<SavingsTip>> getSavingsTips() async {
    return await _dataSource.getSavingsTips();
  }
}
