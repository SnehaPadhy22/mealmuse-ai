
import 'package:flutter/material.dart';

import '../services/recipe_api_service.dart';
import 'recipe_details_screen.dart';

class AIChefScreen extends StatefulWidget {
  const AIChefScreen({super.key});

  @override
  State<AIChefScreen> createState() => _AIChefScreenState();
}

class _AIChefScreenState extends State<AIChefScreen> {
  final TextEditingController ingredientsController =
      TextEditingController();

  final RecipeApiService recipeApiService = RecipeApiService();

  String dietaryPreference = 'No preference';
  String mealType = 'Any';
  double cookingTime = 30;

  bool isLoading = false;

  final List<String> dietaryOptions = [
    'No preference',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Gluten-free',
  ];

  final List<String> mealOptions = [
    'Any',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  @override
  void dispose() {
    ingredientsController.dispose();
    super.dispose();
  }

  Future<void> generateRecipe() async {
    final ingredientText = ingredientsController.text.trim();

    if (ingredientText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one ingredient.'),
        ),
      );
      return;
    }

    final ingredients = ingredientText
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid ingredients.'),
        ),
      );
      return;
    }

    if (ingredients.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter no more than 20 ingredients.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final recipe = await recipeApiService.generateRecipe(
        ingredients: ingredients,
        dietaryPreference: dietaryPreference,
        cookingTime: cookingTime.round(),
        mealType: mealType,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailsScreen(
            recipe: recipe.toJson(),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'AI Chef',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Let AI cook up something amazing! ✨',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF245B43),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us what ingredients you have, and we will '
              'suggest a delicious recipe.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Ingredients image banner
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/ingredients.png',
                width: double.infinity,
                height: 165,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 165,
                    width: double.infinity,
                    color: const Color(0xFFE1EDE5),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.restaurant,
                      size: 55,
                      color: Color(0xFF245B43),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              '1. What ingredients do you have?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: ingredientsController,
              maxLines: 4,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Example: Tomato, onion, potato, rice...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              '2. Dietary preference',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dietaryPreference,
                  isExpanded: true,
                  items: dietaryOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              dietaryPreference = value;
                            });
                          }
                        },
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              '3. Meal type',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mealOptions.map((option) {
                final selected = mealType == option;

                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: isLoading
                      ? null
                      : (_) {
                          setState(() {
                            mealType = option;
                          });
                        },
                  selectedColor: const Color(0xFF245B43),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            const Text(
              '4. Maximum cooking time',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cooking time',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '${cookingTime.round()} minutes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF245B43),
                  ),
                ),
              ],
            ),

            Slider(
              value: cookingTime,
              min: 5,
              max: 180,
              divisions: 35,
              activeColor: const Color(0xFF245B43),
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        cookingTime = value;
                      });
                    },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : generateRecipe,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  isLoading
                      ? 'Generating Recipe...'
                      : 'Generate My Recipe',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245B43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
