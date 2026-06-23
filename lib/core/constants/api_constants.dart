class ApiConstants {
  ApiConstants._();

  // Change this to your server IP when testing on a physical device.
  // 10.0.2.2 is the Android emulator's alias for localhost.
  // For iOS simulator, localhost works directly.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Endpoints
  static const String analyze = '/meals/analyze';
  static const String meals = '/meals';
  static const String dashboardToday = '/dashboard/today';
}
