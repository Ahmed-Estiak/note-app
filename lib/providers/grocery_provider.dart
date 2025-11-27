import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../models/grocery_list.dart';
import '../models/purchase.dart';
import '../models/trip_history.dart';

class GroceryProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  
  List<GroceryList> _lists = [];
  List<Purchase> _purchaseHistory = [];
  List<TripHistory> _tripHistory = [];
  String? _selectedListId;
  bool _isLoaded = false;
  bool _hasSeenInstructions = false;

  List<GroceryList> get lists => _lists;
  List<Purchase> get purchaseHistory => _purchaseHistory;
  List<TripHistory> get tripHistory => _tripHistory;
  bool get isLoaded => _isLoaded;
  bool get hasSeenInstructions => _hasSeenInstructions;
  
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
      
      // Load trip history
      final tripHistoryJson = prefs.getString('trip_history');
      if (tripHistoryJson != null) {
        final List<dynamic> decoded = jsonDecode(tripHistoryJson);
        _tripHistory = decoded.map((json) => TripHistory.fromJson(json)).toList();
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
      
      // Load instructions flag
      _hasSeenInstructions = prefs.getBool('has_seen_instructions') ?? false;
      
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
      
      // Save trip history
      final tripHistoryJson = jsonEncode(_tripHistory.map((t) => t.toJson()).toList());
      await prefs.setString('trip_history', tripHistoryJson);
      
      // Save selected list ID
      if (_selectedListId != null) {
        await prefs.setString('selected_list_id', _selectedListId!);
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Mark instructions as seen
  Future<void> markInstructionsAsSeen() async {
    _hasSeenInstructions = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_instructions', true);
    } catch (e) {
      debugPrint('Error saving instructions flag: $e');
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

  Future<void> renameList(String listId, String newName) async {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;
    
    _lists[listIndex] = _lists[listIndex].copyWith(name: newName);
    
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

    // Get the old item to check if name changed
    final oldItem = _lists[listIndex].items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => updatedItem,
    );

    final updatedItems = _lists[listIndex].items.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();

    _lists[listIndex] = _lists[listIndex].copyWith(items: updatedItems);

    // If the name changed, update all purchase history with this itemId
    if (oldItem.name.toLowerCase().trim() != updatedItem.name.toLowerCase().trim()) {
      _updatePurchaseHistoryItemName(itemId, updatedItem.name);
    }

    notifyListeners();
    await save();
  }

  // Update item name across all purchase history
  void _updatePurchaseHistoryItemName(String itemId, String newName) {
    final normalizedName = newName.toLowerCase().trim();
    for (int i = 0; i < _purchaseHistory.length; i++) {
      if (_purchaseHistory[i].itemId == itemId) {
        _purchaseHistory[i] = Purchase(
          itemName: normalizedName,
          itemId: _purchaseHistory[i].itemId,
          listId: _purchaseHistory[i].listId,
          boughtAt: _purchaseHistory[i].boughtAt,
          price: _purchaseHistory[i].price,
          category: _purchaseHistory[i].category,
        );
      }
    }
  }

  // Find existing itemId for a suggestion name (to link renamed items)
  String? getItemIdForSuggestion(String suggestionName, {String? listId}) {
    final targetListId = listId ?? _selectedListId;
    if (targetListId == null) return null;

    final normalizedName = suggestionName.toLowerCase().trim();
    
    // Find the most recent purchase with this name in this category
    final matchingPurchases = _purchaseHistory
        .where((p) => p.listId == targetListId && p.itemName == normalizedName)
        .toList();
    
    if (matchingPurchases.isEmpty) return null;
    
    // Return the itemId from the most recent purchase
    matchingPurchases.sort((a, b) => b.boughtAt.compareTo(a.boughtAt));
    return matchingPurchases.first.itemId;
  }

  // Update purchase history by original suggestion name (for Magic List edits)
  Future<void> updatePurchaseHistoryByName(String originalName, String newName, {String? listId}) async {
    final targetListId = listId ?? _selectedListId;
    if (targetListId == null) return;

    final normalizedOriginal = originalName.toLowerCase().trim();
    final normalizedNew = newName.toLowerCase().trim();
    
    // If names are the same (just capitalization change), update and return
    if (normalizedOriginal == normalizedNew) {
      final itemId = getItemIdForSuggestion(originalName, listId: targetListId);
      if (itemId != null && itemId.isNotEmpty) {
        _updatePurchaseHistoryItemName(itemId, newName);
        notifyListeners();
        await save();
      }
      return;
    }

    // Find itemId for the original name (the one being renamed FROM)
    final oldItemId = getItemIdForSuggestion(originalName, listId: targetListId);
    if (oldItemId == null || oldItemId.isEmpty) return;

    // Check if the new name already exists (merge scenario)
    final existingItemId = getItemIdForSuggestion(newName, listId: targetListId);
    
    if (existingItemId != null && existingItemId.isNotEmpty && existingItemId != oldItemId) {
      // MERGE: New name already exists with a different itemId
      // Transfer all purchases from oldItemId to existingItemId
      for (int i = 0; i < _purchaseHistory.length; i++) {
        if (_purchaseHistory[i].itemId == oldItemId) {
          _purchaseHistory[i] = Purchase(
            itemName: normalizedNew,
            itemId: existingItemId, // Use the existing itemId
            listId: _purchaseHistory[i].listId,
            boughtAt: _purchaseHistory[i].boughtAt,
            price: _purchaseHistory[i].price,
            category: _purchaseHistory[i].category,
          );
        }
      }
    } else {
      // RENAME: New name doesn't exist, just update the name
      _updatePurchaseHistoryItemName(oldItemId, newName);
    }
    
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
    
    // Add to purchase history with price, category, itemId, and listId
    for (final item in checkedItems) {
      _purchaseHistory.add(Purchase(
        itemName: item.name.toLowerCase().trim(),
        itemId: item.id,
        listId: _selectedListId!,
        boughtAt: now,
        price: item.price,
        category: item.category,
      ));
    }
    
    // Add to trip history
    if (checkedItems.isNotEmpty) {
      final selectedList = _lists[listIndex];
      final tripItems = checkedItems.map((item) => TripItem(
        name: item.name,
        quantity: item.quantity,
        price: item.price,
      )).toList();
      
      final trip = TripHistory(
        id: _uuid.v4(),
        completedAt: now,
        listName: selectedList.name,
        listId: _selectedListId!,
        items: tripItems,
      );
      
      _tripHistory.insert(0, trip); // Add to beginning (newest first)
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
  List<String> predictedItemNames({int limit = 8, String? listId}) {
    if (_purchaseHistory.isEmpty) return [];
    
    // Use current selected list if no listId provided
    final targetListId = listId ?? _selectedListId;
    if (targetListId == null) return [];
    
    // Filter purchases by listId (category-specific)
    final categoryPurchases = _purchaseHistory
        .where((purchase) => purchase.listId == targetListId)
        .toList();
    
    if (categoryPurchases.isEmpty) return [];
    
    // Group purchases by item name or item ID
    final Map<String, List<Purchase>> grouped = {};
    for (final purchase in categoryPurchases) {
      // Group by itemId if available, otherwise by itemName
      final key = purchase.itemId.isNotEmpty ? purchase.itemId : purchase.itemName;
      grouped.putIfAbsent(key, () => []).add(purchase);
    }
    
    // Calculate score for each item (frequency × recency)
    final Map<String, double> scores = {};
    final Map<String, String> keyToName = {}; // Map key to latest item name
    final now = DateTime.now();
    
    for (final entry in grouped.entries) {
      final key = entry.key;
      final purchases = entry.value;
      
      // Get the most recent item name (for renamed items)
      keyToName[key] = purchases.last.itemName;
      
      // Frequency: number of times purchased
      final frequency = purchases.length.toDouble();
      
      // Recency: inverse of days since last purchase (higher = more recent)
      final lastPurchase = purchases.map((p) => p.boughtAt).reduce((a, b) => a.isAfter(b) ? a : b);
      final daysSinceLastPurchase = now.difference(lastPurchase).inDays + 1;
      final recency = 1.0 / daysSinceLastPurchase;
      
      // Score = frequency × recency
      scores[key] = frequency * recency;
    }
    
    // Sort by score and return top items
    final sortedItems = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Deduplicate by normalized name (to avoid showing both "eggs" and "eggs 1")
    final seenNames = <String>{};
    final suggestions = <String>[];
    
    for (final entry in sortedItems) {
      final itemName = keyToName[entry.key]!;
      final normalizedName = itemName.toLowerCase().trim();
      
      // Only add if we haven't seen this normalized name before
      if (!seenNames.contains(normalizedName)) {
        seenNames.add(normalizedName);
        suggestions.add(itemName);
        
        if (suggestions.length >= limit) break;
      }
    }
    
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
