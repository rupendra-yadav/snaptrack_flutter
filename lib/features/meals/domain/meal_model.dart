import '../../../core/constants/api_constants.dart';

class FoodItem {
  final int? id;
  final String name;
  final double? estimatedWeightG;
  final double calories;
  final double proteinG;

  const FoodItem({
    this.id,
    required this.name,
    this.estimatedWeightG,
    required this.calories,
    required this.proteinG,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as int?,
        name: json['name'] as String,
        estimatedWeightG: (json['estimated_weight_g'] as num?)?.toDouble(),
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['protein_g'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'estimated_weight_g': estimatedWeightG,
        'calories': calories,
        'protein_g': proteinG,
      };
}

class Meal {
  final int id;
  final String imagePath;
  final double totalCalories;
  final double totalProtein;
  final DateTime createdAt;
  final List<FoodItem> foodItems;

  const Meal({
    required this.id,
    required this.imagePath,
    required this.totalCalories,
    required this.totalProtein,
    required this.createdAt,
    required this.foodItems,
  });

  /// Full URL to the meal photo served by the backend
  String get imageUrl {
    // imagePath is like "uploads\abc.jpg" or "uploads/abc.jpg"
    final normalized = imagePath.replaceAll('\\', '/');
    return '${ApiConstants.imageBaseUrl}/$normalized';
  }

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] as int,
        imagePath: json['image_path'] as String,
        totalCalories: (json['total_calories'] as num).toDouble(),
        totalProtein: (json['total_protein'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
        foodItems: (json['food_items'] as List<dynamic>)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// Returned by /meals/analyze — not yet saved to DB
class AnalysisResult {
  final List<FoodItem> foods;
  final double totalCalories;
  final double totalProtein;
  final String imagePath;

  const AnalysisResult({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.imagePath,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        foods: (json['foods'] as List<dynamic>)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCalories: (json['total_calories'] as num).toDouble(),
        totalProtein: (json['total_protein'] as num).toDouble(),
        imagePath: json['image_path'] as String,
      );
}

class DashboardData {
  final double totalCalories;
  final double totalProtein;
  final int mealCount;

  const DashboardData({
    required this.totalCalories,
    required this.totalProtein,
    required this.mealCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        totalCalories: (json['total_calories'] as num).toDouble(),
        totalProtein: (json['total_protein'] as num).toDouble(),
        mealCount: json['meal_count'] as int,
      );
}
