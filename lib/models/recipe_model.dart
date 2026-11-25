
class Ingredient {
  final String name;
  final String quantity;

  const Ingredient({
    required this.name,
    required this.quantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}

class Recipe {
  final String recipeName;
  final String description;
  final String preparationTime;
  final String cookingTime;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.recipeName,
    required this.description,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeName: json['recipe_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      preparationTime: json['preparation_time']?.toString() ?? '',
      cookingTime: json['cooking_time']?.toString() ?? '',
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      ingredients: (json['ingredients'] as List? ?? [])
          .whereType<Map>()
          .map(
            (item) => Ingredient.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      instructions: (json['instructions'] as List? ?? [])
          .map((step) => step.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_name': recipeName,
      'description': description,
      'preparation_time': preparationTime,
      'cooking_time': cookingTime,
      'servings': servings,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'instructions': instructions,
    };
  }
}
