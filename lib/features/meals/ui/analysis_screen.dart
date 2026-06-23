import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meal_providers.dart';
import '../../../shared/widgets/loading_overlay.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  // Total summary card
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TotalStat(
                            label: 'Total Calories',
                            value: '${result.totalCalories.toInt()}',
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
                            value: '${result.totalProtein.toInt()}',
                            unit: 'g',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Detected foods',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Food items list
                  ...result.foods.map(
                    (food) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.restaurant,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        title: Text(food.name),
                        subtitle: food.estimatedWeightG != null
                            ? Text('~${food.estimatedWeightG!.toInt()}g')
                            : null,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${food.calories.toInt()} kcal',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${food.proteinG.toInt()}g protein',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confirm button
                  FilledButton.icon(
                    onPressed: mealsState.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(mealsProvider.notifier)
                                .confirmMeal(result);
                            if (!context.mounted) return;
                            ref.read(analysisProvider.notifier).clear();
                            // Pop back to dashboard (pop twice: analysis + add meal)
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Meal saved!'),
                              ),
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
