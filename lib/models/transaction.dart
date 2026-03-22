import 'package:hive/hive.dart';
import 'category_type.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount; // raw amount as typed by user in [currencyCode]

  @HiveField(2)
  final CategoryType category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final bool isExpense;

  @HiveField(6)
  final String currencyCode; // currency the user was using when they saved this

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    required this.isExpense,
    this.currencyCode = 'MAD', // default for old records
  });

  double get signedAmount => isExpense ? -amount : amount;

  bool isSameMonth(DateTime other) =>
      date.year == other.year && date.month == other.month;

  bool isSameWeek(DateTime other) {
    final startOfWeek = other.subtract(Duration(days: other.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Transaction copyWith({
    String? id,
    double? amount,
    CategoryType? category,
    DateTime? date,
    String? note,
    bool? isExpense,
    String? currencyCode,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isExpense: isExpense ?? this.isExpense,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  String toString() => 'Transaction(id: $id, amount: $amount $currencyCode, '
      'category: $category, date: $date, isExpense: $isExpense)';
}
