import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/meal_model.dart';

class MealRepository {
  final _client = ApiClient.instance;

  /// Step 1: Upload photo and get AI analysis (nothing saved yet)
  Future<AnalysisResult> analyzeMeal(File imageFile) async {
    final json = await _client.uploadImage(ApiConstants.analyze, imageFile);
    return AnalysisResult.fromJson(json);
  }

  /// Step 2: Confirm and save the meal
  Future<Meal> confirmMeal(AnalysisResult result) async {
    final json = await _client.post(ApiConstants.meals, {
      'image_path': result.imagePath,
      'foods': result.foods.map((f) => f.toJson()).toList(),
      'total_calories': result.totalCalories,
      'total_protein': result.totalProtein,
    });
    return Meal.fromJson(json);
  }

  /// Get meal history
  Future<List<Meal>> getMeals() async {
    final list = await _client.getList(ApiConstants.meals);
    return list
        .map((e) => Meal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Delete a meal by id
  Future<void> deleteMeal(int id) async {
    await _client.delete('${ApiConstants.meals}/$id');
  }

}