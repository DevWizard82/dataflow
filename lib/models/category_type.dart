import 'package:hive/hive.dart';

part 'category_type.g.dart';

/// Every transaction and budget belongs to one of these categories.
/// The [index] of each value maps directly to AppColors.categories[index].
@HiveType(typeId: 0)
enum CategoryType {
  @HiveField(0)
  food,

  @HiveField(1)
  transport,

  @HiveField(2)
  shopping,

  @HiveField(3)
  bills,

  @HiveField(4)
  health,

  @HiveField(5)
  education,

  @HiveField(6)
  income,

  @HiveField(7)
  other,
}

/// Display helpers — keep all UI strings here, not scattered in widgets.
extension CategoryTypeX on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.food:
        return 'Food';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.bills:
        return 'Bills';
      case CategoryType.health:
        return 'Health';
      case CategoryType.education:
        return 'Education';
      case CategoryType.income:
        return 'Income';
      case CategoryType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case CategoryType.food:
        return '🍔';
      case CategoryType.transport:
        return '🚗';
      case CategoryType.shopping:
        return '🛍';
      case CategoryType.bills:
        return '💡';
      case CategoryType.health:
        return '❤️';
      case CategoryType.education:
        return '📚';
      case CategoryType.income:
        return '💰';
      case CategoryType.other:
        return '📦';
    }
  }

  /// Maps to AppColors.categories[index]
  int get colorIndex => index;
}
