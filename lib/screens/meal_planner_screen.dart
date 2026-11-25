
import 'package:flutter/material.dart';

import '../services/meal_planner_service.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() =>
      _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealPlannerService _mealService = MealPlannerService();

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
  ];

  final Map<String, IconData> mealIcons = {
    'Breakfast': Icons.wb_sunny_outlined,
    'Lunch': Icons.lunch_dining_outlined,
    'Dinner': Icons.dinner_dining_outlined,
  };

  int selectedDay = 0;

  Map<String, Map<String, String>> weeklyMeals = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeeklyPlan();
  }

  // Load weekly meal plan
  Future<void> loadWeeklyPlan() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _mealService.getWeeklyPlan();

      if (!mounted) return;

      setState(() {
        weeklyMeals = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load your meal plan.'),
        ),
      );
    }
  }

  // Add or edit a meal
  Future<void> addMeal(String mealType) async {
    final currentDay = days[selectedDay];
    final existingMeal = weeklyMeals[currentDay]?[mealType];

    final mealName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _MealNameDialog(
          mealType: mealType,
          existingMeal: existingMeal,
        );
      },
    );

    if (!mounted || mealName == null) return;

    final cleanedMealName = mealName.trim();

    if (cleanedMealName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a meal name.'),
        ),
      );
      return;
    }

    try {
      await _mealService.saveMeal(
        day: currentDay,
        mealType: mealType,
        mealName: cleanedMealName,
      );

      if (!mounted) return;

      setState(() {
        weeklyMeals.putIfAbsent(currentDay, () => {});
        weeklyMeals[currentDay]![mealType] = cleanedMealName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mealType saved for $currentDay!'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save meal. Please try again.'),
        ),
      );
    }
  }

  // Remove a meal
  Future<void> removeMeal(String mealType) async {
    final currentDay = days[selectedDay];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Meal?'),
        content: Text(
          'Remove $mealType from $currentDay?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _mealService.deleteMeal(
        day: currentDay,
        mealType: mealType,
      );

      if (!mounted) return;

      setState(() {
        weeklyMeals[currentDay]?.remove(mealType);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal removed from your plan.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove meal. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = days[selectedDay];
    final meals = weeklyMeals[currentDay] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'Weekly Meal Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        actions: [
          IconButton(
            tooltip: 'Refresh meal plan',
            onPressed: isLoading ? null : loadWeeklyPlan,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF245B43),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan your meals! 🥗',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF245B43),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Organize your meals and make your week easier.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Select a day',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 45,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selected = selectedDay == index;

                        return ChoiceChip(
                          label: Text(
                            days[index].substring(0, 3),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              selectedDay = index;
                            });
                          },
                          selectedColor: const Color(0xFF245B43),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    '$currentDay\'s Meals',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  ...mealTypes.map((mealType) {
                    final mealName = meals[mealType];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F1E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              mealIcons[mealType],
                              color: const Color(0xFF245B43),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mealType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  mealName ?? 'No meal planned',
                                  style: TextStyle(
                                    color: mealName == null
                                        ? Colors.grey
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mealName != null)
                            IconButton(
                              tooltip: 'Remove meal',
                              onPressed: () => removeMeal(mealType),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                            ),
                          IconButton(
                            tooltip: mealName == null
                                ? 'Add meal'
                                : 'Edit meal',
                            onPressed: () => addMeal(mealType),
                            icon: Icon(
                              mealName == null
                                  ? Icons.add_circle_outline
                                  : Icons.edit_outlined,
                              color: const Color(0xFF245B43),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F1E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF245B43),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Plan your meals ahead to save time '
                            'and make grocery shopping easier!',
                            style: TextStyle(
                              color: Color(0xFF245B43),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Meal name dialog
// The TextFormField manages its own editing state.
// No manually disposed TextEditingController is used.

class _MealNameDialog extends StatefulWidget {
  final String mealType;
  final String? existingMeal;

  const _MealNameDialog({
    required this.mealType,
    this.existingMeal,
  });

  @override
  State<_MealNameDialog> createState() =>
      _MealNameDialogState();
}

class _MealNameDialogState extends State<_MealNameDialog> {
  late String mealName;

  @override
  void initState() {
    super.initState();
    mealName = widget.existingMeal ?? '';
  }

  void _save() {
    Navigator.of(context).pop(mealName.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingMeal == null
            ? 'Add ${widget.mealType}'
            : 'Edit ${widget.mealType}',
      ),
      content: TextFormField(
        initialValue: mealName,
        autofocus: false,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Enter meal name',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          mealName = value;
        },
        onFieldSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
