
import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/favourites_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailsScreen> createState() =>
      _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final FavouritesService favouritesService = FavouritesService();

  bool isFavourite = false;
  bool isLoading = false;
  int? favouriteId;

  @override
  void initState() {
    super.initState();
    checkFavouriteStatus();
  }

  Future<void> checkFavouriteStatus() async {
    try {
      final favourites = await favouritesService.getFavourites();
      final currentRecipe = jsonEncode(widget.recipe);

      for (final savedRecipe in favourites) {
        final saved = Map<String, dynamic>.from(savedRecipe);
        final id = saved.remove('id');

        if (jsonEncode(saved) == currentRecipe) {
          if (!mounted) return;

          setState(() {
            isFavourite = true;
            favouriteId = id as int?;
          });

          return;
        }
      }
    } catch (_) {
      // Keep the screen usable if the database is unavailable.
    }
  }

  Future<void> toggleFavourite() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isFavourite && favouriteId != null) {
        await favouritesService.removeFavourite(favouriteId!);

        if (!mounted) return;

        setState(() {
          isFavourite = false;
          favouriteId = null;
        });
      } else {
        await favouritesService.addFavourite(widget.recipe);

        final favourites = await favouritesService.getFavourites();

        int? savedId;

        for (final savedRecipe in favourites) {
          final saved = Map<String, dynamic>.from(savedRecipe);
          final id = saved.remove('id');

          if (jsonEncode(saved) == jsonEncode(widget.recipe)) {
            savedId = id as int?;
            break;
          }
        }

        if (!mounted) return;

        setState(() {
          isFavourite = true;
          favouriteId = savedId;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavourite
                ? 'Recipe added to favourites!'
                : 'Recipe removed from favourites!',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update favourites. Please try again.',
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
    final recipe = widget.recipe;

    final ingredients = (recipe['ingredients'] as List?) ?? [];
    final instructions = (recipe['instructions'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        actions: [
          IconButton(
            onPressed: isLoading ? null : toggleFavourite,
            tooltip: 'Save to favourites',
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: isFavourite ? Colors.red : null,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/healthy_bowl.png',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: const Color(0xFFE1EDE5),
                    child: const Icon(
                      Icons.restaurant,
                      size: 65,
                      color: Color(0xFF245B43),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            // Recipe title
            Text(
              recipe['recipe_name']?.toString() ??
                  'Your Delicious Recipe',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF245B43),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              recipe['description']?.toString() ??
                  'A delicious recipe created just for you.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 22),

            // Recipe information
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    Icons.timer_outlined,
                    'Prep Time',
                    recipe['preparation_time']?.toString() ?? 'N/A',
                  ),
                  _infoItem(
                    Icons.local_fire_department_outlined,
                    'Cook Time',
                    recipe['cooking_time']?.toString() ?? 'N/A',
                  ),
                  _infoItem(
                    Icons.people_outline,
                    'Servings',
                    recipe['servings']?.toString() ?? 'N/A',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Ingredients heading
            Row(
              children: [
                const Icon(
                  Icons.shopping_basket_outlined,
                  color: Color(0xFF245B43),
                  size: 24,
                ),
                const SizedBox(width: 9),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${ingredients.length} items',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ...ingredients.map((ingredient) {
              final name = ingredient is Map
                  ? ingredient['name']?.toString() ?? ''
                  : ingredient.toString();

              final quantity = ingredient is Map
                  ? ingredient['quantity']?.toString() ?? ''
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF245B43),
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      quantity,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 25),

            // Instructions heading
            const Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF245B43),
                  size: 24,
                ),
                SizedBox(width: 9),
                Text(
                  'Cooking Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ...instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFF245B43),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        instruction.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 15),

            // Favourite button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : toggleFavourite,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                label: Text(
                  isLoading
                      ? 'Please wait...'
                      : isFavourite
                          ? 'Saved to Favourites'
                          : 'Save to Favourites',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245B43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF245B43),
          size: 25,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
