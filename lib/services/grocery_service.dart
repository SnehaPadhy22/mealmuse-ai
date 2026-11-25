
import 'storage_service.dart';

class GroceryService {
  final StorageService _storage = StorageService.instance;

  // Add a new grocery item.
  Future<int> addItem(String name) async {
    final db = await _storage.database;

    return db.insert(
      'groceries',
      {
        'name': name.trim(),
        'purchased': 0,
      },
    );
  }

  // Retrieve all grocery items.
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await _storage.database;

    return db.query(
      'groceries',
      orderBy: 'id DESC',
    );
  }

  // Update purchased status.
  Future<void> updatePurchased({
    required int id,
    required bool purchased,
  }) async {
    final db = await _storage.database;

    await db.update(
      'groceries',
      {
        'purchased': purchased ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an individual grocery item.
  Future<void> deleteItem(int id) async {
    final db = await _storage.database;

    await db.delete(
      'groceries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Remove all purchased items.
  Future<void> removePurchasedItems() async {
    final db = await _storage.database;

    await db.delete(
      'groceries',
      where: 'purchased = ?',
      whereArgs: [1],
    );
  }
}
