import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/water_provider.dart';

class WaterTrackerCard extends ConsumerWidget {
  final int dailyGoalGlasses;

  const WaterTrackerCard({
    super.key,
    this.dailyGoalGlasses = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(waterProvider);
    final theme = Theme.of(context);

    return waterAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (glasses) {
        final progress = (glasses / dailyGoalGlasses).clamp(0.0, 1.0);
        final isGoalMet = glasses >= dailyGoalGlasses;

        return Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop,
                        size: 18,
                        color: theme.colorScheme.onSecondaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      'Water',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const Spacer(),
                    if (isGoalMet)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Goal met!',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$glasses',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ $dailyGoalGlasses glasses',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress dots
                Row(
                  children: List.generate(
                    dailyGoalGlasses,
                    (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i < glasses
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSecondaryContainer
                                  .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Add / remove buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: glasses <= 0
                            ? null
                            : () =>
                                ref.read(waterProvider.notifier).removeGlass(),
                        icon: const Icon(Icons.remove, size: 16),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              theme.colorScheme.onSecondaryContainer,
                          side: BorderSide(
                            color: theme.colorScheme.onSecondaryContainer
                                .withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            ref.read(waterProvider.notifier).addGlass(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add glass'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
