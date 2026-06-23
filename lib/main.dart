import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/ui/dashboard_screen.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod — wraps the entire app
    const ProviderScope(
      child: SnapTrackApp(),
    ),
  );
}

class SnapTrackApp extends StatelessWidget {
  const SnapTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapTrack',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
