
import 'dart:convert';

import 'storage_service.dart';

class FavouritesService {
  final StorageService _storage = StorageService.instance;

  // Compare recipes using their actual content.
  bool _areRecipesEqual(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    return first['recipe_name'] == second['recipe_name'] &&
        first['description'] == second['description'] &&
        first['preparation_time'] == second['preparation_time'] &&
        first['cooking_time'] == second['cooking_time'] &&
        first['servings'] == second['servings'] &&
        jsonEncode(first['ingredients']) ==
            jsonEncode(second['ingredients']) &&
        jsonEncode(first['instructions']) ==
            jsonEncode(second['instructions']);
  }

  // Save a recipe to favourites.
  Future<void> addFavourite(
    Map<String, dynamic> recipe,
  ) async {
    if (await isFavourite(recipe)) {
      return;
    }

    final db = await _storage.database;

    await db.insert('favourites', {
      'recipe_json': jsonEncode(recipe),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Retrieve all saved recipes.
  Future<List<Map<String, dynamic>>> getFavourites() async {
    final db = await _storage.database;

    final results = await db.query(
      'favourites',
      orderBy: 'created_at DESC',
    );

    return results.map((row) {
      return {
        'id': row['id'],
        ...Map<String, dynamic>.from(
          jsonDecode(row['recipe_json'] as String),
        ),
      };
    }).toList();
  }

  // Remove a recipe from favourites.
  Future<void> removeFavourite(int id) async {
    final db = await _storage.database;

    await db.delete(
      'favourites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check whether a recipe is already saved.
  Future<bool> isFavourite(
    Map<String, dynamic> recipe,
  ) async {
    final favourites = await getFavourites();

    for (final savedRecipe in favourites) {
      final saved = Map<String, dynamic>.from(savedRecipe);
      saved.remove('id');

      if (_areRecipesEqual(saved, recipe)) {
        return true;
      }
    }

    return false;
  }
}
