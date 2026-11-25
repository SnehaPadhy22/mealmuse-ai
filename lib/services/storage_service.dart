
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();

  factory StorageService() => instance;

  StorageService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mealmuse.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Saved recipes
        await db.execute('''
          CREATE TABLE favourites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recipe_json TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        // Weekly meal plans
        await db.execute('''
          CREATE TABLE meal_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            meal_name TEXT NOT NULL,
            UNIQUE(day, meal_type)
          )
        ''');

        // Grocery shopping list
        await db.execute('''
          CREATE TABLE groceries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            purchased INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }
}
