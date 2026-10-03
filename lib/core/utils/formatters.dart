import 'package:intl/intl.dart';

/// Formatting utilities for EnergyWatch numbers, currencies, units, and dates.
class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _decimalCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _oneDecimal = NumberFormat('0.0');
  static final NumberFormat _twoDecimals = NumberFormat('0.00');

  /// Formats currency with or without decimals, e.g. ₹1,576 or ₹1,576.50
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return _decimalCurrencyFormat.format(amount);
    }
    return _currencyFormat.format(amount.round());
  }

  /// Formats energy consumption with unit: e.g. "6.72 kWh" or "184.5 kWh"
  static String formatEnergy(double kwh, {int decimals = 2}) {
    if (decimals == 1) {
      return '${_oneDecimal.format(kwh)} kWh';
    }
    return '${_twoDecimals.format(kwh)} kWh';
  }

  /// Formats active power load with unit: e.g. "1.84 kW"
  static String formatPower(double kw, {int decimals = 2}) {
    if (kw < 1.0 && kw > 0) {
      final watts = (kw * 1000).round();
      return '$watts W';
    }
    if (decimals == 1) {
      return '${_oneDecimal.format(kw)} kW';
    }
    return '${_twoDecimals.format(kw)} kW';
  }

  /// Formats percentage value: e.g. "39%", "+5.4%", "-8.0%"
  static String formatPercent(double percent, {bool includeSign = false, int decimals = 1}) {
    final formatted = decimals == 0 ? percent.round().toString() : percent.toStringAsFixed(decimals);
    if (includeSign && percent > 0) {
      return '+$formatted%';
    }
    return '$formatted%';
  }

  /// Formats a DateTime to short day format: e.g. "Mon", "Tue"
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Formats a DateTime to date string: e.g. "02 Oct"
  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  /// Formats a DateTime to full date: e.g. "Oct 02, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats a DateTime to time: e.g. "08:00 AM"
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Formats a time difference into a readable relative string: "Just now", "2 mins ago"
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 20) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return formatDayMonth(date);
    }
  }
}
