
import 'package:flutter/material.dart';

import '../services/favourites_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_details_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() =>
      _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final FavouritesService favouritesService =
      FavouritesService();

  late Future<List<Map<String, dynamic>>> favouritesFuture;

  @override
  void initState() {
    super.initState();
    loadFavourites();
  }

  void loadFavourites() {
    favouritesFuture = favouritesService.getFavourites();
  }

  Future<void> removeFavourite(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favourite?'),
        content: const Text(
          'Are you sure you want to remove this recipe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
      await favouritesService.removeFavourite(id);

      if (!mounted) return;

      setState(() {
        loadFavourites();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe removed from favourites.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to remove recipe. Please try again.',
          ),
        ),
      );
    }
  }

  void openRecipe(Map<String, dynamic> recipe) {
    final recipeDetails = Map<String, dynamic>.from(recipe);
    recipeDetails.remove('id');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipe: recipeDetails,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          loadFavourites();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'My Favourites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: favouritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF245B43),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load favourite recipes.',
              ),
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 65,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No favourite recipes yet!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved recipes will appear here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final recipeId = recipe['id'] as int?;

              return RecipeCard(
  name: recipe['recipe_name']?.toString() ??
      'Untitled Recipe',
  time: recipe['cooking_time']?.toString() ??
      'N/A',
  category: 'Saved Recipe',
  emoji: '🍽️',
  imageAsset: 'assets/images/healthy_bowl.png',
  isFavorite: true,
  onTap: () => openRecipe(recipe),
  onFavoriteTap: recipeId == null
      ? null
      : () => removeFavourite(recipeId),
);
            },
          );
        },
      ),
    );
  }
}
