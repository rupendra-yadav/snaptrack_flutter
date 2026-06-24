import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../../meals/providers/meal_providers.dart';
import '../../meals/ui/add_meal_screen.dart';
import '../../meals/ui/history_screen.dart';
import '../../settings/ui/settings_screen.dart';
import '../../settings/providers/goals_provider.dart';
import '../../../shared/widgets/macro_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final mealsAsync = ref.watch(mealsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          ref.invalidate(mealsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Today',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Macro cards with progress
            dashboardAsync.when(
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (data) => goalsAsync.when(
                loading: () => const SizedBox(height: 160),
                error: (e, _) => _ErrorCard(message: e.toString()),
                data: (goals) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MacroCard(
                            label: 'Calories',
                            value: data.totalCalories.toInt().toString(),
                            unit: 'kcal',
                            icon: Icons.local_fire_department,
                            color: theme.colorScheme.primaryContainer,
                            progress: data.totalCalories / goals.calories,
                            goalLabel: '/ ${goals.calories.toInt()}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MacroCard(
                            label: 'Protein',
                            value: data.totalProtein.toInt().toString(),
                            unit: 'g',
                            icon: Icons.fitness_center,
                            color: theme.colorScheme.secondaryContainer,
                            progress: data.totalProtein / goals.protein,
                            goalLabel: '/ ${goals.protein.toInt()}g',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MacroCard(
                      label: 'Meals logged',
                      value: data.mealCount.toString(),
                      unit: 'today',
                      icon: Icons.restaurant,
                      color: theme.colorScheme.tertiaryContainer,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Today's meals",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Today's meals with swipe to delete
            mealsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
              data: (meals) {
                final today = DateTime.now();
                final todayMeals = meals
                    .where((m) =>
                        m.createdAt.year == today.year &&
                        m.createdAt.month == today.month &&
                        m.createdAt.day == today.day)
                    .toList();

                if (todayMeals.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            'No meals logged today.\nTap + to add your first meal.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: todayMeals.map((meal) {
                    final time =
                        '${meal.createdAt.hour.toString().padLeft(2, '0')}:${meal.createdAt.minute.toString().padLeft(2, '0')}';

                    return Dismissible(
                      key: Key('meal_${meal.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete meal?'),
                            content: const Text(
                                'This will remove the meal and update today\'s totals.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await ref
                            .read(mealsProvider.notifier)
                            .deleteMeal(meal.id);
                        ref.invalidate(dashboardProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meal deleted')),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            child: Icon(Icons.restaurant,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text('${meal.foodItems.length} item(s)'),
                          subtitle: Text(
                            meal.foodItems.map((f) => f.name).join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${meal.totalCalories.toInt()} kcal',
                                style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary),
                              ),
                              Text(
                                '${meal.totalProtein.toInt()}g protein',
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(time,
                                  style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMealScreen()),
        ),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Meal'),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer)),
      ),
    );
  }
}
