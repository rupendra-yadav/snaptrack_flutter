import 'package:shared_preferences/shared_preferences.dart';

class GoalsStorage {
  GoalsStorage._();
  static final GoalsStorage instance = GoalsStorage._();

  static const _keyCalories = 'goal_calories';
  static const _keyProtein = 'goal_protein';

  // Sensible defaults
  static const double defaultCalories = 2000;
  static const double defaultProtein = 150;

  Future<double> getCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyCalories) ?? defaultCalories;
  }

  Future<double> getProteinGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyProtein) ?? defaultProtein;
  }

  Future<void> setCalorieGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyCalories, value);
  }

  Future<void> setProteinGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyProtein, value);
  }
}
