import 'package:hive/hive.dart';
import 'category_type.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  final String id; // uuid v4

  @HiveField(1)
  final CategoryType category;

  @HiveField(2)
  final double monthlyLimit; // the cap set by the user

  @HiveField(3)
  final int month; // 1–12

  @HiveField(4)
  final int year; // e.g. 2025

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.month,
    required this.year,
  });

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Does this budget belong to [date]'s month/year?
  bool isForMonth(DateTime date) => month == date.month && year == date.year;

  /// Utilization ratio clamped to [0.0 – 1.0].
  /// Pass [spent] from TransactionProvider.spentForCategory().
  double utilizationRatio(double spent) =>
      (spent / monthlyLimit).clamp(0.0, 1.0);

  /// Percentage string e.g. "72%"
  String utilizationLabel(double spent) =>
      '${(utilizationRatio(spent) * 100).round()}%';

  /// Remaining amount (floored at 0).
  double remaining(double spent) =>
      (monthlyLimit - spent).clamp(0.0, double.infinity);

  /// Budget status based on utilization.
  BudgetStatus status(double spent) {
    final ratio = utilizationRatio(spent);
    if (ratio >= 0.90) return BudgetStatus.critical; // ≥ 90% → red
    if (ratio >= 0.65) return BudgetStatus.warning; // ≥ 65% → amber
    return BudgetStatus.onTrack; //  < 65% → green
  }

  /// Create a copy with optional overrides.
  Budget copyWith({
    String? id,
    CategoryType? category,
    double? monthlyLimit,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  @override
  String toString() =>
      'Budget(id: $id, category: $category, limit: $monthlyLimit, '
      '$month/$year)';
}

/// Used by the Budgets screen to decide card color and label.
enum BudgetStatus {
  onTrack, // green  — < 65%
  warning, // amber  — 65–89%
  critical, // red    — ≥ 90%
}
