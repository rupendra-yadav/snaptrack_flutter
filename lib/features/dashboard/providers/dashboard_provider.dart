import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../../meals/domain/meal_model.dart';

// Auto-dispose so it refetches every time the dashboard comes into view
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  return DashboardRepository().getToday();
});
