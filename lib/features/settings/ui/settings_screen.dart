import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goals_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  bool _initialized = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _initControllers(Goals goals) {
    if (_initialized) return;
    _caloriesController = TextEditingController(
      text: goals.calories.toInt().toString(),
    );
    _proteinController = TextEditingController(
      text: goals.protein.toInt().toString(),
    );
    _initialized = true;
  }

  Future<void> _save() async {
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);

    if (calories == null || protein == null || calories <= 0 || protein <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers.')),
      );
      return;
    }

    await ref.read(goalsProvider.notifier).setCalorieGoal(calories);
    await ref.read(goalsProvider.notifier).setProteinGoal(protein);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          _initControllers(goals);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Daily Goals',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Set your daily calorie and protein targets. '
                'Progress bars on the dashboard will reflect these.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Calorie goal
              Text('Calorie Goal', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'kcal',
                  hintText: '2000',
                ),
              ),

              const SizedBox(height: 24),

              // Protein goal
              Text('Protein Goal', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'g',
                  hintText: '150',
                ),
              ),

              const SizedBox(height: 40),

              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Goals'),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'About',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('SnapTrack'),
                subtitle: const Text('AI-powered meal tracker · v1.0.0'),
                leading: Icon(Icons.restaurant,
                    color: theme.colorScheme.primary),
              ),
            ],
          );
        },
      ),
    );
  }
}
