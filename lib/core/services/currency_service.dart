import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

/// Fetches live exchange rates from open.er-api.com and caches them in Hive.
/// All transactions are stored in MAD (base currency).
/// When the user switches currency, amounts are converted on the fly.
class CurrencyService {
  CurrencyService._();

  static const _apiUrl = 'https://open.er-api.com/v6/latest/MAD';
  static const _ratesKey = 'exchangeRates';
  static const _tsKey = 'exchangeRatesTimestamp';
  static const _cacheTtl = Duration(hours: 6);

  // In-memory cache so we don't hit Hive on every format() call
  static Map<String, double> _rates = {'MAD': 1.0};
  static bool _initialized = false;

  static Map<String, double> get rates => _rates;

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Call once after HiveService.init().
  /// Loads cached rates, then refreshes in background if stale.
  static Future<void> init() async {
    final box = await HiveService.openBox(HiveService.settingsBox);

    // Load cached rates
    final cached = box.get(_ratesKey);
    if (cached != null) {
      _rates = Map<String, double>.from((cached as Map)
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble())));
      _initialized = true;
    }

    // Refresh if stale or missing
    final ts = box.get(_tsKey) as int?;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isStale = ts == null || now - ts > _cacheTtl.inMilliseconds;

    if (isStale) {
      // Fire and forget — don't block startup
      _fetchAndCache(box);
    }
  }

  static Future<void> _fetchAndCache(Box box) async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rawRates = data['rates'] as Map<String, dynamic>;
          _rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
          _initialized = true;

          // Persist to Hive
          await box.put(_ratesKey, _rates);
          await box.put(_tsKey, DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (_) {
      // Silent fail — use cached or fallback rates
    }
  }

  // ── Conversion ────────────────────────────────────────────────────────────

  /// Convert [amount] from MAD to [targetCurrency].
  /// Falls back to 1:1 if rate is not available.
  static double convert(double amount, String targetCurrency) {
    if (targetCurrency == 'MAD') return amount;
    final rate = _rates[targetCurrency] ?? 1.0;
    return amount * rate;
  }

  /// Convert [amount] from [fromCurrency] back to MAD (our storage base).
  static double toMAD(double amount, String fromCurrency) {
    if (fromCurrency == 'MAD') return amount;
    final rate = _rates[fromCurrency] ?? 1.0;
    if (rate == 0) return amount;
    return amount / rate;
  }

  /// Get the rate for a currency relative to MAD.
  static double rateFor(String currency) => _rates[currency] ?? 1.0;

  static bool get isInitialized => _initialized;
}
