import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2)
class Exercise {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<ExerciseSet> sets;

  @HiveField(3)
  final int? key;

  Exercise({
    required this.name,
    required this.date,
    required this.sets,
    this.key,
  });

// Used to create temp copies of exercise obj for updating values
  Exercise copyWith({
    String? name,
    DateTime? date,
    List<ExerciseSet>? sets,
    int? key,
  }) {
    return Exercise(
      name: name ?? this.name,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      key: key ?? this.key,
    );
  }
}

@HiveType(typeId: 3)
class ExerciseSet {
  @HiveField(0)
  final double weight;

  @HiveField(1)
  final int reps;

  ExerciseSet({
    required this.weight,
    required this.reps,
  });
}
