import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/water_storage.dart';

class WaterNotifier extends AsyncNotifier<int> {
  final _storage = WaterStorage.instance;

  @override
  Future<int> build() => _storage.getGlassesToday();

  Future<void> addGlass() async {
    await _storage.addGlass();
    state = AsyncData((state.value ?? 0) + 1);
  }

  Future<void> removeGlass() async {
    final current = state.value ?? 0;
    if (current <= 0) return;
    await _storage.removeGlass();
    state = AsyncData(current - 1);
  }
}

final waterProvider = AsyncNotifierProvider<WaterNotifier, int>(
  WaterNotifier.new,
);
