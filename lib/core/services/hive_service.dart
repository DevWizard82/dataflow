// 📍 lib/core/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/category_type.dart';
import '../../models/transaction.dart';
import '../../models/budget.dart';

/// Single entry point for all Hive initialisation.
/// Call [HiveService.init()] once in main() before runApp().
/// Use [HiveService.openBox()] everywhere else — guards against double-open crashes.
class HiveService {
  HiveService._();

  // ── Box name constants — never use raw strings elsewhere ──────────────────
  static const String settingsBox = 'settings';
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';

  static Future<void> init() async {
    await Hive.initFlutter();

    // ── Register TypeAdapters ─────────────────────────────────────────────
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryTypeAdapter()); // typeId: 0
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionAdapter()); // typeId: 1
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetAdapter()); // typeId: 2
    }

    // ── Pre-open data boxes ───────────────────────────────────────────────
    await openBox<Transaction>(transactionsBox);
    await openBox<Budget>(budgetsBox);
    // 'settings' is opened on-demand by ThemeProvider & CurrencyProvider
  }

  /// Opens a Hive box only if it isn't already open.
  /// Always use this instead of [Hive.openBox] directly to avoid:
  ///   "HiveError: The box is already open"
  static Future<Box<T>> openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return Hive.openBox<T>(name);
  }
}
