import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/services/hive_service.dart';
import '../core/services/currency_service.dart';
import '../models/transaction.dart';
import '../models/category_type.dart';

class TransactionProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  late Box<Transaction> _box;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  List<Transaction> get all {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> init() async {
    _box = await HiveService.openBox<Transaction>(HiveService.transactionsBox);
    _initialized = true;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTransaction({
    required double amount, // raw amount as typed (in activeCurrency)
    required CategoryType category,
    required DateTime date,
    required bool isExpense,
    required String currencyCode, // currency active when user typed the amount
    String note = '',
  }) async {
    final tx = Transaction(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      date: date,
      note: note,
      isExpense: isExpense,
      currencyCode: currencyCode,
    );
    await _box.put(tx.id, tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction updated) async {
    await _box.put(updated.id, updated);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }

  // ── Convert any transaction amount to MAD for aggregations ────────────────
  // All math is done in MAD so totals are consistent regardless of which
  // currency was active when the transaction was saved.

  double _toMad(Transaction t) =>
      CurrencyService.toMAD(t.amount, t.currencyCode);

  // ── Filtered lists ─────────────────────────────────────────────────────────

  List<Transaction> forMonth(DateTime month) =>
      all.where((t) => t.isSameMonth(month)).toList();

  List<Transaction> get thisWeek {
    final now = DateTime.now();
    return all.where((t) => t.isSameWeek(now)).toList();
  }

  List<Transaction> recent({int limit = 10}) => all.take(limit).toList();

  List<Transaction> expensesForMonth(DateTime month) =>
      forMonth(month).where((t) => t.isExpense).toList();

  // ── Aggregations (all in MAD internally) ──────────────────────────────────

  double totalIncomeForMonth(DateTime month) => forMonth(month)
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + _toMad(t));

  double totalExpensesForMonth(DateTime month) => forMonth(month)
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + _toMad(t));

  double balanceForMonth(DateTime month) =>
      totalIncomeForMonth(month) - totalExpensesForMonth(month);

  double spentForCategory(CategoryType category, DateTime month) =>
      forMonth(month)
          .where((t) => t.isExpense && t.category == category)
          .fold(0.0, (sum, t) => sum + _toMad(t));

  List<double> get weeklyDailyTotals {
    final totals = List<double>.filled(7, 0.0);
    for (final t in thisWeek) {
      if (!t.isExpense) continue;
      totals[t.date.weekday - 1] += _toMad(t);
    }
    return totals;
  }

  double get weeklyTotal =>
      thisWeek.where((t) => t.isExpense).fold(0.0, (s, t) => s + _toMad(t));

  Map<CategoryType, double> categoryTotalsForMonth(DateTime month) {
    final map = <CategoryType, double>{};
    for (final t in expensesForMonth(month)) {
      map[t.category] = (map[t.category] ?? 0) + _toMad(t);
    }
    return map;
  }

  double categoryPercentage(CategoryType category, DateTime month) {
    final total = totalExpensesForMonth(month);
    if (total == 0) return 0;
    return spentForCategory(category, month) / total;
  }

  Transaction? get highestExpenseEver {
    final expenses = all.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => _toMad(a) > _toMad(b) ? a : b);
  }

  Transaction? highestExpenseForMonth(DateTime month) {
    final expenses = expensesForMonth(month);
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => _toMad(a) > _toMad(b) ? a : b);
  }

  double? get weekOverWeekChange {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final thisTotal = weeklyTotal;
    final lastTotal = all
        .where((t) => t.isExpense && t.isSameWeek(lastWeek))
        .fold(0.0, (s, t) => s + _toMad(t));
    if (lastTotal == 0) return null;
    return ((thisTotal - lastTotal) / lastTotal) * 100;
  }
}
