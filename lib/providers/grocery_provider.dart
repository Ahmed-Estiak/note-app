import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../models/grocery_list.dart';
import '../models/purchase.dart';

class GroceryProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  
  List<GroceryList> _lists = [];
  List<Purchase> _purchaseHistory = [];
  String? _selectedListId;
  bool _isLoaded = false;

  List<GroceryList> get lists => _lists;
  List<Purchase> get purchaseHistory => _purchaseHistory;
  bool get isLoaded => _isLoaded;
  
  GroceryList? get selectedList {
    if (_selectedListId == null) return null;
    try {
      return _lists.firstWhere((list) => list.id == _selectedListId);
    } catch (e) {
      return null;
    }
  }

  // Constructor - initialize with default data
  GroceryProvider() {
    _initializeDefault();
  }

  // Initialize with default data immediately
  void _initializeDefault() {
    final defaultList = GroceryList(
      id: _uuid.v4(),
      name: 'Weekly',
      items: [
        GroceryItem(id: _uuid.v4(), name: ''),
      ],
    );
    _lists.add(defaultList);
    _selectedListId = defaultList.id;
    _isLoaded = true;
  }

  // Load data from shared preferences
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load lists
      final listsJson = prefs.getString('lists');
      if (listsJson != null) {
        final List<dynamic> decoded = jsonDecode(listsJson);
        final loadedLists = decoded.map((json) => GroceryList.fromJson(json)).toList();
        if (loadedLists.isNotEmpty) {
          _lists = loadedLists;
        }
      }
      
      // Load purchase history
      final historyJson = prefs.getString('purchase_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _purchaseHistory = decoded.map((json) => Purchase.fromJson(json)).toList();
      }
      
      // Load selected list ID
      final savedListId = prefs.getString('selected_list_id');
      if (savedListId != null && _lists.any((list) => list.id == savedListId)) {
        _selectedListId = savedListId;
      }
      
      // Ensure selected list is valid
      if (_selectedListId == null || !_lists.any((list) => list.id == _selectedListId)) {
        _selectedListId = _lists.first.id;
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Even on error, ensure we have default data
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Save data to shared preferences
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save lists
      final listsJson = jsonEncode(_lists.map((list) => list.toJson()).toList());
      await prefs.setString('lists', listsJson);
      
      // Save purchase history
      final historyJson = jsonEncode(_purchaseHistory.map((p) => p.toJson()).toList());
      await prefs.setString('purchase_history', historyJson);
      
      // Save selected list ID
      if (_selectedListId != null) {
        await prefs.setString('selected_list_id', _selectedListId!);
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Select a list
  void selectList(String listId) {
    if (_lists.any((list) => list.id == listId)) {
      _selectedListId = listId;
      notifyListeners();
      save();
    }
  }

  // Create a new list
  Future<void> createList(String name) async {
    final newList = GroceryList(
      id: _uuid.v4(),
      name: name,
      items: [
        GroceryItem(id: _uuid.v4(), name: ''),
      ],
    );
    _lists.add(newList);
    _selectedListId = newList.id;
    notifyListeners();
    await save();
  }

  // Delete a list
  Future<void> deleteList(String listId) async {
    _lists.removeWhere((list) => list.id == listId);
    
    // If deleted list was selected, select first list
    if (_selectedListId == listId && _lists.isNotEmpty) {
      _selectedListId = _lists.first.id;
    }
    
    notifyListeners();
    await save();
  }

  // ===== ITEM METHODS =====

  // Add item to selected list
  Future<void> addItem(GroceryItem item, {int? position}) async {
    if (_selectedListId == null) return;
    
    final listIndex = _lists.indexWhere((list) => list.id == _selectedListId);
    if (listIndex == -1) return;

    final updatedItems = List<GroceryItem>.from(_lists[listIndex].items);
    
    // Insert at specific position or append to end
    if (position != null && position >= 0 && position <= updatedItems.length) {
      updatedItems.insert(position, item);
    } else {
      updatedItems.add(item);
    }
    
    _lists[listIndex] = _lists[listIndex].copyWith(items: updatedItems);

    notifyListeners();
    await save();
  }

  // Update item in selected list
  Future<void> updateItem(String itemId, GroceryItem updatedItem) async {
    if (_selectedListId == null) return;
    
    final listIndex = _lists.indexWhere((list) => list.id == _selectedListId);
    if (listIndex == -1) return;

    final updatedItems = _lists[listIndex].items.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();

    _lists[listIndex] = _lists[listIndex].copyWith(items: updatedItems);

    notifyListeners();
    await save();
  }

  // Delete item from selected list
  Future<void> deleteItem(String itemId) async {
    if (_selectedListId == null) return;
    
    final listIndex = _lists.indexWhere((list) => list.id == _selectedListId);
    if (listIndex == -1) return;

    var updatedItems = _lists[listIndex].items.where((item) => item.id != itemId).toList();
    
    // Ensure there's always at least one empty bullet point
    if (updatedItems.isEmpty) {
      updatedItems = [GroceryItem(id: _uuid.v4(), name: '')];
    }
    
    _lists[listIndex] = _lists[listIndex].copyWith(items: updatedItems);

    notifyListeners();
    await save();
  }

  // Toggle item done status
  Future<void> toggleItemDone(String itemId) async {
    if (_selectedListId == null) return;
    
    final listIndex = _lists.indexWhere((list) => list.id == _selectedListId);
    if (listIndex == -1) return;

    final updatedItems = _lists[listIndex].items.map((item) {
      return item.id == itemId ? item.copyWith(done: !item.done) : item;
    }).toList();

    _lists[listIndex] = _lists[listIndex].copyWith(items: updatedItems);

    notifyListeners();
    await save();
  }

  // Complete shopping for selected list
  Future<void> completeShopping() async {
    if (_selectedListId == null) return;
    
    final listIndex = _lists.indexWhere((list) => list.id == _selectedListId);
    if (listIndex == -1) return;

    final now = DateTime.now();
    final checkedItems = _lists[listIndex].items.where((item) => item.done).toList();
    
    // Add to purchase history with price and category
    for (final item in checkedItems) {
      _purchaseHistory.add(Purchase(
        itemName: item.name.toLowerCase().trim(),
        boughtAt: now,
        price: item.price,
        category: item.category,
      ));
    }
    
    // Remove checked items from list
    var remainingItems = _lists[listIndex].items.where((item) => !item.done).toList();
    
    // Ensure there's always at least one empty bullet point
    if (remainingItems.isEmpty) {
      remainingItems = [GroceryItem(id: _uuid.v4(), name: '')];
    }
    
    _lists[listIndex] = _lists[listIndex].copyWith(items: remainingItems);
    
    notifyListeners();
    await save();
  }

  // Get predicted items
  List<String> predictedItemNames({int limit = 8}) {
    if (_purchaseHistory.isEmpty) return [];
    
    // Group purchases by item name
    final Map<String, List<Purchase>> grouped = {};
    for (final purchase in _purchaseHistory) {
      grouped.putIfAbsent(purchase.itemName, () => []).add(purchase);
    }
    
    // Calculate score for each item (frequency × recency)
    final Map<String, double> scores = {};
    final now = DateTime.now();
    
    for (final entry in grouped.entries) {
      final itemName = entry.key;
      final purchases = entry.value;
      
      // Frequency: number of times purchased
      final frequency = purchases.length.toDouble();
      
      // Recency: inverse of days since last purchase (higher = more recent)
      final lastPurchase = purchases.map((p) => p.boughtAt).reduce((a, b) => a.isAfter(b) ? a : b);
      final daysSinceLastPurchase = now.difference(lastPurchase).inDays + 1;
      final recency = 1.0 / daysSinceLastPurchase;
      
      // Score = frequency × recency
      scores[itemName] = frequency * recency;
    }
    
    // Sort by score and return top items
    final sortedItems = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final suggestions = sortedItems
        .take(limit)
        .map((entry) => entry.key)
        .toList();
    
    return suggestions;
  }

  // Get items expiring soon from selected list
  List<GroceryItem> getExpiringSoonItems() {
    if (_selectedListId == null) return [];
    
    final list = selectedList;
    if (list == null) return [];
    
    return list.items
        .where((item) => item.isExpiringSoon && !item.done)
        .toList();
  }

  // Get total spent this month
  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    double total = 0.0;
    
    // Get all purchases this month and sum their prices
    final thisMonthPurchases = _purchaseHistory
        .where((p) => p.boughtAt.isAfter(firstDayOfMonth))
        .toList();
    
    for (final purchase in thisMonthPurchases) {
      if (purchase.price != null) {
        total += purchase.price!;
      }
    }
    
    return total;
  }

  // Get spending by category this month
  Map<String, double> getSpendingByCategory() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final Map<String, double> categoryTotals = {};
    
    // Get all purchases this month and group by category
    final thisMonthPurchases = _purchaseHistory
        .where((p) => p.boughtAt.isAfter(firstDayOfMonth))
        .toList();
    
    for (final purchase in thisMonthPurchases) {
      if (purchase.price != null) {
        categoryTotals[purchase.category] = 
            (categoryTotals[purchase.category] ?? 0.0) + purchase.price!;
      }
    }
    
    return categoryTotals;
  }
}
