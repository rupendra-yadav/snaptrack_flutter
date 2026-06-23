import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../meals/domain/meal_model.dart';

class DashboardRepository {
  final _client = ApiClient.instance;

  Future<DashboardData> getToday() async {
    final json = await _client.get(ApiConstants.dashboardToday);
    return DashboardData.fromJson(json);
  }
}
