// 📍 lib/providers/currency_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/services/hive_service.dart';
import '../core/services/currency_service.dart';

class CurrencyOption {
  final String code;
  final String symbol;
  final String flag;
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.flag,
  });
}

/// Manages selected display currency.
/// All amounts in Hive are stored in MAD.
/// format() converts MAD → selected currency using live rates.
class CurrencyProvider extends ChangeNotifier {
  static const _currencyKey = 'currencyCode';

  static const List<CurrencyOption> all = [
    CurrencyOption(code: 'MAD', symbol: 'د.م.', flag: '🇲🇦'),
    CurrencyOption(code: 'USD', symbol: '\$', flag: '🇺🇸'),
    CurrencyOption(code: 'EUR', symbol: '€', flag: '🇪🇺'),
    CurrencyOption(code: 'GBP', symbol: '£', flag: '🇬🇧'),
    CurrencyOption(code: 'SAR', symbol: '﷼', flag: '🇸🇦'),
  ];

  late Box _box;
  CurrencyOption _selected = all.first; // default: MAD
  bool _initialized = false;

  CurrencyOption get selected => _selected;
  String get symbol => _selected.symbol;
  String get flag => _selected.flag;
  bool get isInitialized => _initialized;

  // ── Format helpers ────────────────────────────────────────────────────────

  /// Format a MAD amount converted to the currently selected currency.
  /// Use this for aggregated totals (balance, totals, budgets).
  String format(double madAmount) {
    final converted = CurrencyService.convert(madAmount, _selected.code);
    return _formatValue(converted);
  }

  /// Compact format — no decimals.
  String formatCompact(double madAmount) {
    final converted = CurrencyService.convert(madAmount, _selected.code);
    final formatted = converted.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
        );
    return '${_selected.symbol} $formatted';
  }

  /// Format a transaction's raw amount:
  /// converts from the transaction's own currency → currently selected currency.
  /// Use this wherever you display a single transaction's amount.
  String formatTransaction(double amount, String txCurrencyCode) {
    // Step 1: convert from tx currency → MAD
    final inMad = CurrencyService.toMAD(amount, txCurrencyCode);
    // Step 2: convert MAD → selected display currency
    final converted = CurrencyService.convert(inMad, _selected.code);
    return _formatValue(converted);
  }

  String _formatValue(double value) {
    final formatted = value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (m) => '${m[1]},',
        );
    return '${_selected.symbol} $formatted';
  }

  /// Format without any conversion — raw value already in display currency.
  String formatRaw(double amount) => _formatValue(amount);

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _box = await HiveService.openBox(HiveService.settingsBox);
    final code = _box.get(_currencyKey, defaultValue: 'MAD') as String;
    _selected = all.firstWhere(
      (c) => c.code == code,
      orElse: () => all.first,
    );
    _initialized = true;
    notifyListeners();
  }

  void setCurrency(CurrencyOption option) {
    if (_selected.code == option.code) return;
    _selected = option;
    _box.put(_currencyKey, option.code);
    notifyListeners(); // triggers rebuild — all format() calls re-run with new rates
  }

  void setCurrencyByCode(String code) {
    final option = all.firstWhere(
      (c) => c.code == code,
      orElse: () => all.first,
    );
    setCurrency(option);
  }
}
