
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe_model.dart';

class RecipeApiService {
  // Android emulator backend address.
  static const String baseUrl = 'https://mealmuse-ai.onrender.com';

  Future<Recipe> generateRecipe({
    required List<String> ingredients,
    required String dietaryPreference,
    required int cookingTime,
    required String mealType,
  }) async {
    final url = Uri.parse('$baseUrl/generate-recipe');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'ingredients': ingredients,
              'dietary_preference': dietaryPreference,
              'cooking_time': cookingTime,
              'meal_type': mealType,
            }),
          )
          .timeout(const Duration(seconds: 60));

      dynamic responseData;

      try {
        responseData = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'The server returned an invalid response. Please try again.',
        );
      }

      if (response.statusCode == 200) {
        if (responseData is Map &&
            responseData['success'] == true &&
            responseData['recipe'] is Map) {
          return Recipe.fromJson(
            Map<String, dynamic>.from(responseData['recipe']),
          );
        }

        throw Exception('Invalid recipe response from server.');
      }

      final message = responseData is Map
          ? responseData['detail'] ?? 'Recipe generation failed.'
          : 'Recipe generation failed.';

      throw Exception(message.toString());
    } on http.ClientException {
      throw Exception('Unable to connect to the recipe server.');
    } on FormatException {
      throw Exception('The server returned an invalid response.');
    } catch (error) {
      rethrow;
    }
  }
}
