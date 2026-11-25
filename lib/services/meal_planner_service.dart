
import 'package:sqflite/sqflite.dart';
import 'storage_service.dart';

class MealPlannerService {
  final StorageService _storage = StorageService.instance;

  Future<void> saveMeal({
    required String day,
    required String mealType,
    required String mealName,
  }) async {
    final db = await _storage.database;

    await db.insert(
      'meal_plans',
      {
        'day': day,
        'meal_type': mealType,
        'meal_name': mealName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Map<String, String>>> getWeeklyPlan() async {
    final db = await _storage.database;

    final results = await db.query('meal_plans');

    final Map<String, Map<String, String>> weeklyPlan = {};

    for (final row in results) {
      final day = row['day'] as String;
      final mealType = row['meal_type'] as String;
      final mealName = row['meal_name'] as String;

      weeklyPlan.putIfAbsent(day, () => {});
      weeklyPlan[day]![mealType] = mealName;
    }

    return weeklyPlan;
  }

  Future<Map<String, String>> getMealsForDay(String day) async {
    final db = await _storage.database;

    final results = await db.query(
      'meal_plans',
      where: 'day = ?',
      whereArgs: [day],
    );

    return {
      for (final row in results)
        row['meal_type'] as String: row['meal_name'] as String,
    };
  }

  Future<void> deleteMeal({
    required String day,
    required String mealType,
  }) async {
    final db = await _storage.database;

    await db.delete(
      'meal_plans',
      where: 'day = ? AND meal_type = ?',
      whereArgs: [day, mealType],
    );
  }
}
