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

  // Calculator fields
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _activityLevel = 'moderate';
  String _goal = 'maintain';
  Map<String, dynamic>? _calculatorResult;

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initControllers(Goals goals) {
    if (_initialized) return;
    _caloriesController =
        TextEditingController(text: goals.calories.toInt().toString());
    _proteinController =
        TextEditingController(text: goals.protein.toInt().toString());
    _initialized = true;
  }

  void _calculate() {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (age == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // BMI
    final heightM = height / 100;
    final bmi = weight / (heightM * heightM);

    // BMR using Mifflin-St Jeor (male assumed for MVP)
    final bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;

    // Activity multiplier
    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    final tdee = bmr * (multipliers[_activityLevel] ?? 1.55);

    // Goal adjustment
    double targetCalories;
    switch (_goal) {
      case 'lose':
        targetCalories = tdee - 500;
        break;
      case 'gain':
        targetCalories = tdee + 300;
        break;
      default:
        targetCalories = tdee;
    }

    // Protein: 1.8g per kg body weight
    final targetProtein = weight * 1.8;

    // BMI category
    String bmiCategory;
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi < 25) {
      bmiCategory = 'Normal weight';
    } else if (bmi < 30) {
      bmiCategory = 'Overweight';
    } else {
      bmiCategory = 'Obese';
    }

    setState(() {
      _calculatorResult = {
        'bmi': bmi,
        'bmiCategory': bmiCategory,
        'tdee': tdee,
        'targetCalories': targetCalories,
        'targetProtein': targetProtein,
      };
    });
  }

  Future<void> _applyCalculatorResult() async {
    if (_calculatorResult == null) return;
    final cal = _calculatorResult!['targetCalories'] as double;
    final protein = _calculatorResult!['targetProtein'] as double;

    _caloriesController.text = cal.toInt().toString();
    _proteinController.text = protein.toInt().toString();

    await ref.read(goalsProvider.notifier).setCalorieGoal(cal);
    await ref.read(goalsProvider.notifier).setProteinGoal(protein);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals updated from calculator!')),
    );
  }

  Future<void> _saveManual() async {
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
              // Manual goals section
              Text('Daily Goals', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Set manually or use the calculator below.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text('Calorie Goal', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    suffixText: 'kcal', hintText: '2000'),
              ),
              const SizedBox(height: 16),
              Text('Protein Goal', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(suffixText: 'g', hintText: '150'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveManual,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Save Goals'),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              // Calculator section
              Row(
                children: [
                  Icon(Icons.calculate, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Goal Calculator', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your stats to auto-calculate recommended calorie and protein goals.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Age', suffixText: 'yrs'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Weight', suffixText: 'kg'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Height', suffixText: 'cm'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text('Activity Level', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(
                      value: 'sedentary', child: Text('Sedentary (desk job)')),
                  DropdownMenuItem(
                      value: 'light',
                      child: Text('Light (1-3x/week exercise)')),
                  DropdownMenuItem(
                      value: 'moderate',
                      child: Text('Moderate (3-5x/week exercise)')),
                  DropdownMenuItem(
                      value: 'active',
                      child: Text('Active (6-7x/week exercise)')),
                  DropdownMenuItem(
                      value: 'very_active',
                      child: Text('Very active (athlete)')),
                ],
                onChanged: (v) => setState(() => _activityLevel = v!),
              ),

              const SizedBox(height: 16),
              Text('Goal', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'lose', label: Text('Lose weight')),
                  ButtonSegment(value: 'maintain', label: Text('Maintain')),
                  ButtonSegment(value: 'gain', label: Text('Gain muscle')),
                ],
                selected: {_goal},
                onSelectionChanged: (v) =>
                    setState(() => _goal = v.first),
              ),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Calculate'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),

              // Calculator result
              if (_calculatorResult != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Results',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            )),
                        const SizedBox(height: 12),
                        _ResultRow(
                          label: 'BMI',
                          value:
                              '${(_calculatorResult!['bmi'] as double).toStringAsFixed(1)} — ${_calculatorResult!['bmiCategory']}',
                        ),
                        _ResultRow(
                          label: 'Daily energy burn (TDEE)',
                          value:
                              '${(_calculatorResult!['tdee'] as double).toInt()} kcal',
                        ),
                        _ResultRow(
                          label: 'Recommended calories',
                          value:
                              '${(_calculatorResult!['targetCalories'] as double).toInt()} kcal',
                          highlight: true,
                        ),
                        _ResultRow(
                          label: 'Recommended protein',
                          value:
                              '${(_calculatorResult!['targetProtein'] as double).toInt()}g',
                          highlight: true,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _applyCalculatorResult,
                            child: const Text('Apply these goals'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('About', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('SnapTrack'),
                subtitle: const Text('AI-powered meal tracker · v1.0.0'),
                leading:
                    Icon(Icons.restaurant, color: theme.colorScheme.primary),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              )),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight:
                  highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
