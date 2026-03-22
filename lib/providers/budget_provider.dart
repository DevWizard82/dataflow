// 📍 lib/providers/budget_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/services/hive_service.dart';
import '../models/budget.dart';
import '../models/category_type.dart';

class BudgetProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  late Box<Budget> _box;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _box = await HiveService.openBox<Budget>(HiveService.budgetsBox);
    _initialized = true;
    notifyListeners();
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  /// All budgets for a given month/year.
  List<Budget> forMonth(DateTime month) =>
      _box.values.where((b) => b.isForMonth(month)).toList()
        ..sort((a, b) => a.category.index.compareTo(b.category.index));

  /// Budget for a specific category + month, or null if not set.
  Budget? forCategory(CategoryType category, DateTime month) {
    try {
      return _box.values.firstWhere(
        (b) => b.category == category && b.isForMonth(month),
      );
    } catch (_) {
      return null;
    }
  }

  /// Whether the current month has at least one budget set.
  bool get hasAnyBudget => forMonth(DateTime.now()).isNotEmpty;

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> setBudget({
    required CategoryType category,
    required double monthlyLimit,
    required DateTime month,
  }) async {
    // If a budget already exists for this category+month → update it
    final existing = forCategory(category, month);
    if (existing != null) {
      final updated = existing.copyWith(monthlyLimit: monthlyLimit);
      await _box.put(existing.id, updated);
    } else {
      final budget = Budget(
        id: _uuid.v4(),
        category: category,
        monthlyLimit: monthlyLimit,
        month: month.month,
        year: month.year,
      );
      await _box.put(budget.id, budget);
    }
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }

  // ── Status helpers (used by Budgets screen) ───────────────────────────────

  /// Overall status for the month.
  /// "ON TRACK" if no budget is critical or warning.
  MonthStatus monthStatus(
      DateTime month, Map<CategoryType, double> categorySpending) {
    final budgets = forMonth(month);
    if (budgets.isEmpty) return MonthStatus.noBudgets;

    bool hasWarning = false;
    for (final b in budgets) {
      final spent = categorySpending[b.category] ?? 0;
      final status = b.status(spent);
      if (status == BudgetStatus.critical) return MonthStatus.critical;
      if (status == BudgetStatus.warning) hasWarning = true;
    }
    return hasWarning ? MonthStatus.warning : MonthStatus.onTrack;
  }
}

/// Overall month-level budget health.
enum MonthStatus {
  onTrack, // all budgets green
  warning, // at least one amber
  critical, // at least one red
  noBudgets, // nothing set yet
}
