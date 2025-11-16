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

  // Add item to selected list
  Future<void> addItem(GroceryItem item) async {
    if (selectedList == null) return;
    
    final updatedItems = [...selectedList!.items, item];
    final updatedList = selectedList!.copyWith(items: updatedItems);
    
    final index = _lists.indexWhere((list) => list.id == _selectedListId);
    _lists[index] = updatedList;
    
    notifyListeners();
    await save();
  }

  // Update an item
  Future<void> updateItem(String itemId, GroceryItem updatedItem) async {
    if (selectedList == null) return;
    
    final updatedItems = selectedList!.items.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();
    
    final updatedList = selectedList!.copyWith(items: updatedItems);
    final index = _lists.indexWhere((list) => list.id == _selectedListId);
    _lists[index] = updatedList;
    
    notifyListeners();
    await save();
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    if (selectedList == null) return;
    
    final updatedItems = selectedList!.items.where((item) => item.id != itemId).toList();
    final updatedList = selectedList!.copyWith(items: updatedItems);
    
    final index = _lists.indexWhere((list) => list.id == _selectedListId);
    _lists[index] = updatedList;
    
    notifyListeners();
    await save();
  }

  // Toggle item done status
  Future<void> toggleItemDone(String itemId) async {
    if (selectedList == null) return;
    
    final updatedItems = selectedList!.items.map((item) {
      return item.id == itemId ? item.copyWith(done: !item.done) : item;
    }).toList();
    
    final updatedList = selectedList!.copyWith(items: updatedItems);
    final index = _lists.indexWhere((list) => list.id == _selectedListId);
    _lists[index] = updatedList;
    
    notifyListeners();
    await save();
  }

  // Complete shopping trip - move checked items to history
  Future<void> completeShopping() async {
    if (selectedList == null) return;
    
    final now = DateTime.now();
    final checkedItems = selectedList!.items.where((item) => item.done).toList();
    
    // Add to purchase history
    for (final item in checkedItems) {
      _purchaseHistory.add(Purchase(
        itemName: item.name.toLowerCase().trim(),
        boughtAt: now,
      ));
    }
    
    // Remove checked items from list
    final remainingItems = selectedList!.items.where((item) => !item.done).toList();
    final updatedList = selectedList!.copyWith(items: remainingItems);
    
    final index = _lists.indexWhere((list) => list.id == _selectedListId);
    _lists[index] = updatedList;
    
    notifyListeners();
    await save();
  }

  // Get predicted items based on frequency × recency
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
    
    // Filter out items already in the current list
    final currentItemNames = selectedList?.items
        .map((item) => item.name.toLowerCase().trim())
        .toSet() ?? {};
    
    final suggestions = sortedItems
        .where((entry) => !currentItemNames.contains(entry.key))
        .take(limit)
        .map((entry) => entry.key)
        .toList();
    
    return suggestions;
  }

  // Get items expiring soon (within 3 days)
  List<GroceryItem> get expiringSoonItems {
    if (selectedList == null) return [];
    return selectedList!.items
        .where((item) => item.isExpiringSoon && !item.done)
        .toList();
  }

  // Get total spent this month
  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    double total = 0.0;
    
    // Get all purchases this month
    final thisMonthPurchases = _purchaseHistory
        .where((p) => p.boughtAt.isAfter(firstDayOfMonth))
        .toList();
    
    // Find corresponding items in all lists to get prices
    for (final purchase in thisMonthPurchases) {
      for (final list in _lists) {
        for (final item in list.items) {
          if (item.name.toLowerCase().trim() == purchase.itemName && item.price != null) {
            total += item.price!;
            break;
          }
        }
      }
    }
    
    return total;
  }

  // Get spending by category this month
  Map<String, double> getSpendingByCategory() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final Map<String, double> categoryTotals = {};
    
    // Get all purchases this month
    final thisMonthPurchases = _purchaseHistory
        .where((p) => p.boughtAt.isAfter(firstDayOfMonth))
        .toList();
    
    // Find corresponding items in all lists to get prices and categories
    for (final purchase in thisMonthPurchases) {
      for (final list in _lists) {
        for (final item in list.items) {
          if (item.name.toLowerCase().trim() == purchase.itemName && item.price != null) {
            categoryTotals[item.category] = (categoryTotals[item.category] ?? 0.0) + item.price!;
            break;
          }
        }
      }
    }
    
    return categoryTotals;
  }
}

