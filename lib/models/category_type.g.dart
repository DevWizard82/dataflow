// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 0;

  @override
  CategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryType.food;
      case 1:
        return CategoryType.transport;
      case 2:
        return CategoryType.shopping;
      case 3:
        return CategoryType.bills;
      case 4:
        return CategoryType.health;
      case 5:
        return CategoryType.education;
      case 6:
        return CategoryType.income;
      case 7:
        return CategoryType.other;
      default:
        return CategoryType.food;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    switch (obj) {
      case CategoryType.food:
        writer.writeByte(0);
        break;
      case CategoryType.transport:
        writer.writeByte(1);
        break;
      case CategoryType.shopping:
        writer.writeByte(2);
        break;
      case CategoryType.bills:
        writer.writeByte(3);
        break;
      case CategoryType.health:
        writer.writeByte(4);
        break;
      case CategoryType.education:
        writer.writeByte(5);
        break;
      case CategoryType.income:
        writer.writeByte(6);
        break;
      case CategoryType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
