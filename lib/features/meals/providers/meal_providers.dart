import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meal_repository.dart';
import '../domain/meal_model.dart';
import '../../dashboard/providers/dashboard_provider.dart';

// ---------------------------------------------------------------------------
// Analysis provider — holds the in-flight AI result between analyze & confirm
// ---------------------------------------------------------------------------
class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  final _repo = MealRepository();

  @override
  Future<AnalysisResult?> build() async => null;

  Future<void> analyze(File imageFile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.analyzeMeal(imageFile));
  }

  void clear() => state = const AsyncData(null);
}

final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(
  AnalysisNotifier.new,
);

// ---------------------------------------------------------------------------
// Meals provider — meal history list
// ---------------------------------------------------------------------------
class MealsNotifier extends AsyncNotifier<List<Meal>> {
  final _repo = MealRepository();

  @override
  Future<List<Meal>> build() => _repo.getMeals();

  /// Called after user confirms the analysis result.
  /// Saves the meal then refreshes both history and dashboard.
  Future<void> confirmMeal(AnalysisResult result) async {
    await _repo.confirmMeal(result);
    state = await AsyncValue.guard(() => _repo.getMeals());
    ref.invalidate(dashboardProvider);
  }

  /// Delete a meal by id and refresh the list.
  Future<void> deleteMeal(int id) async {
    await _repo.deleteMeal(id);
    state = await AsyncValue.guard(() => _repo.getMeals());
    ref.invalidate(dashboardProvider);
  }
}

final mealsProvider = AsyncNotifierProvider<MealsNotifier, List<Meal>>(
  MealsNotifier.new,
);
