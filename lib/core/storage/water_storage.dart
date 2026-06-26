import 'package:shared_preferences/shared_preferences.dart';

class WaterStorage {
  WaterStorage._();
  static final WaterStorage instance = WaterStorage._();

  String get _todayKey {
    final now = DateTime.now();
    return 'water_${now.year}_${now.month}_${now.day}';
  }

  Future<int> getGlassesToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayKey) ?? 0;
  }

  Future<void> addGlass() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_todayKey) ?? 0;
    await prefs.setInt(_todayKey, current + 1);
  }

  Future<void> removeGlass() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_todayKey) ?? 0;
    if (current > 0) await prefs.setInt(_todayKey, current - 1);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todayKey, 0);
  }
}
