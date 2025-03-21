// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionGoalsAdapter extends TypeAdapter<NutritionGoals> {
  @override
  final int typeId = 1;

  @override
  NutritionGoals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoals(
      calories: fields[0] as double,
      carbs: fields[1] as double,
      protein: fields[2] as double,
      fats: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionGoals obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.calories)
      ..writeByte(1)
      ..write(obj.carbs)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.fats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
