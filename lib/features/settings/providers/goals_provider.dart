import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/goals_storage.dart';

class Goals {
  final double calories;
  final double protein;

  const Goals({required this.calories, required this.protein});

  Goals copyWith({double? calories, double? protein}) => Goals(
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
      );
}

class GoalsNotifier extends AsyncNotifier<Goals> {
  final _storage = GoalsStorage.instance;

  @override
  Future<Goals> build() async => Goals(
        calories: await _storage.getCalorieGoal(),
        protein: await _storage.getProteinGoal(),
      );

  Future<void> setCalorieGoal(double value) async {
    await _storage.setCalorieGoal(value);
    state = AsyncData(state.value!.copyWith(calories: value));
  }

  Future<void> setProteinGoal(double value) async {
    await _storage.setProteinGoal(value);
    state = AsyncData(state.value!.copyWith(protein: value));
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, Goals>(
  GoalsNotifier.new,
);
