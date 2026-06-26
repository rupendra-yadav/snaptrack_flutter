import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_providers.dart';
import '../domain/meal_model.dart';
import '../../../shared/widgets/loading_overlay.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  // Local editable copy of food items
  List<FoodItem>? _editableFoods;

  void _initEditable(List<FoodItem> foods) {
    _editableFoods ??= List.from(foods);
  }

  double get _totalCalories =>
      _editableFoods?.fold(0, (sum, f) => sum! + f.calories) ?? 0;
  double get _totalProtein =>
      _editableFoods?.fold(0, (sum, f) => sum! + f.proteinG) ?? 0;

  Future<void> _editFoodItem(int index) async {
    final food = _editableFoods![index];
    final calController =
        TextEditingController(text: food.calories.toInt().toString());
    final proteinController =
        TextEditingController(text: food.proteinG.toInt().toString());
    final weightController = TextEditingController(
        text: food.estimatedWeightG?.toInt().toString() ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(food.name,
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimated weight',
                suffixText: 'g',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Protein',
                suffixText: 'g',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _editableFoods![index] = FoodItem(
                      name: food.name,
                      estimatedWeightG:
                          double.tryParse(weightController.text),
                      calories:
                          double.tryParse(calController.text) ?? food.calories,
                      proteinG: double.tryParse(proteinController.text) ??
                          food.proteinG,
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ) {
    final analysisAsync = ref.watch(analysisProvider);
    final mealsState = ref.watch(mealsProvider);
    final theme = Theme.of(context);

    return analysisAsync.when(
      loading: () => const Scaffold(
        body: LoadingOverlay(message: 'Analyzing...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Analysis')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (result) {
        if (result == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Analysis')),
            body: const Center(child: Text('No result available.')),
          );
        }

        _initEditable(result.foods);

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text('Review Meal'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(analysisProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Totals card — updates live as user edits
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TotalStat(
                            label: 'Total Calories',
                            value: '${_totalCalories.toInt()}',
                            unit: 'kcal',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.3),
                          ),
                          _TotalStat(
                            label: 'Total Protein',
                            value: '${_totalProtein.toInt()}',
                            unit: 'g',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Detected foods',
                          style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        'Tap to edit',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Food items — tappable for editing
                  ...(_editableFoods ?? []).asMap().entries.map(
                        (entry) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _editFoodItem(entry.key),
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Icon(Icons.restaurant,
                                  color: theme.colorScheme.secondary),
                            ),
                            title: Text(entry.value.name),
                            subtitle: entry.value.estimatedWeightG != null
                                ? Text(
                                    '~${entry.value.estimatedWeightG!.toInt()}g')
                                : null,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${entry.value.calories.toInt()} kcal',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${entry.value.proteinG.toInt()}g protein',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: mealsState.isLoading
                        ? null
                        : () async {
                            // Build updated result with edited foods
                            final updatedResult = AnalysisResult(
                              foods: _editableFoods!,
                              totalCalories: _totalCalories,
                              totalProtein: _totalProtein,
                              imagePath: result.imagePath,
                            );
                            await ref
                                .read(mealsProvider.notifier)
                                .confirmMeal(updatedResult);
                            if (!context.mounted) return;
                            ref.read(analysisProvider.notifier).clear();
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meal saved!')),
                            );
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm & Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-analyze'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            if (mealsState.isLoading)
              const LoadingOverlay(message: 'Saving meal...'),
          ],
        );
      },
    );
  }
}

class _TotalStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _TotalStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
