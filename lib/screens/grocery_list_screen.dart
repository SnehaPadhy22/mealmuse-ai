
import 'package:flutter/material.dart';

import '../services/grocery_service.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final TextEditingController itemController = TextEditingController();
  final GroceryService _groceryService = GroceryService();

  List<Map<String, dynamic>> groceryItems = [];
  final Set<int> updatingItems = {};

  bool isLoading = true;
  bool isAdding = false;
  bool isRemovingPurchased = false;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
  }

  bool isPurchased(dynamic value) {
    return value == true || value == 1;
  }

  Future<void> loadItems({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final items = await _groceryService.getItems();

      if (!mounted) return;

      setState(() {
        groceryItems = items
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('GROCERY LOAD ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load grocery items.'),
        ),
      );
    }
  }

  Future<void> addItem() async {
    final itemName = itemController.text.trim();

    if (itemName.isEmpty || isAdding) return;

    if (itemName.length > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item name cannot exceed 60 characters.'),
        ),
      );
      return;
    }

    final alreadyExists = groceryItems.any(
      (item) =>
          item['name'].toString().toLowerCase() ==
          itemName.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is already in your grocery list.'),
        ),
      );
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      await _groceryService.addItem(itemName);

      if (!mounted) return;

      itemController.clear();
      await loadItems();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grocery item added successfully.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('GROCERY ADD ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add item. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  Future<void> removeItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text(
          'Are you sure you want to remove this item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _groceryService.deleteItem(id);

      if (!mounted) return;

      await loadItems();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from grocery list.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('GROCERY DELETE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete item.'),
        ),
      );
    }
  }

  Future<void> togglePurchased(int id, bool value) async {
    if (updatingItems.contains(id)) return;

    setState(() {
      updatingItems.add(id);
    });

    try {
      await _groceryService.updatePurchased(
        id: id,
        purchased: value,
      );

      if (!mounted) return;

      setState(() {
        final index = groceryItems.indexWhere(
          (item) => item['id'] == id,
        );

        if (index != -1) {
          groceryItems[index] = Map<String, dynamic>.from(
            groceryItems[index],
          );

          groceryItems[index]['purchased'] = value ? 1 : 0;
        }
      });
    } catch (e, stackTrace) {
      debugPrint('GROCERY UPDATE ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update item: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingItems.remove(id);
        });
      }
    }
  }

  Future<void> removePurchasedItems() async {
    if (isRemovingPurchased) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Purchased Items?'),
        content: const Text(
          'This will permanently remove all purchased items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Remove All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      isRemovingPurchased = true;
    });

    try {
      await _groceryService.removePurchasedItems();

      if (!mounted) return;

      await loadItems();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchased items removed successfully.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('GROCERY CLEAR ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove purchased items.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRemovingPurchased = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchasedCount = groceryItems
        .where((item) => isPurchased(item['purchased']))
        .length;

    final remainingCount = groceryItems.length - purchasedCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'My Grocery List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        actions: [
          IconButton(
            tooltip: 'Refresh grocery list',
            onPressed: isLoading
                ? null
                : () => loadItems(showLoader: true),
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
                    'Shopping made easier! 🛒',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF245B43),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep track of everything you need to buy.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grocery summary
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF245B43),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem(
                          'Total Items',
                          '${groceryItems.length}',
                        ),
                        _summaryItem(
                          'Purchased',
                          '$purchasedCount',
                        ),
                        _summaryItem(
                          'Remaining',
                          '$remainingCount',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Add an item',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: itemController,
                          enabled: !isAdding,
                          maxLength: 60,
                          onSubmitted: (_) => addItem(),
                          textCapitalization:
                              TextCapitalization.sentences,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter grocery item...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 52,
                        width: 52,
                        child: ElevatedButton(
                          onPressed: isAdding ? null : addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF245B43),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Your Shopping List',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (groceryItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Your grocery list is empty.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Add items you need to buy!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...groceryItems.map((item) {
                      final id = item['id'] as int;
                      final name = item['name'] as String;
                      final purchased =
                          isPurchased(item['purchased']);
                      final isUpdating = updatingItems.contains(id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: purchased,
                              activeColor: const Color(0xFF245B43),
                              onChanged: isUpdating
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        togglePurchased(id, value);
                                      }
                                    },
                            ),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: purchased
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: purchased
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: isUpdating
                                  ? null
                                  : () => removeItem(id),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  if (purchasedCount > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isRemovingPurchased
                            ? null
                            : removePurchasedItems,
                        icon: isRemovingPurchased
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.cleaning_services_outlined,
                              ),
                        label: Text(
                          isRemovingPurchased
                              ? 'Removing...'
                              : 'Remove Purchased Items',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF245B43),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
