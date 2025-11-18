import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../widgets/list_selector.dart';
import '../widgets/bullet_item.dart';
import '../widgets/add_edit_item_sheet.dart';
import '../widgets/suggestions_sheet.dart';
import '../widgets/expiring_banner.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final selectedList = provider.selectedList;

    if (selectedList == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final expiringItems = provider.getExpiringSoonItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonotic'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List selector
          const ListSelector(),
          
          // Expiring banner
          if (expiringItems.isNotEmpty)
            ExpiringBanner(expiringItems: expiringItems),

          // Items list
          Expanded(
            child: selectedList.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first item',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedList.items.length,
                    itemBuilder: (context, index) {
                      final item = selectedList.items[index];
                      return BulletItem(
                        item: item,
                        onTextChanged: (text) {
                          if (text.trim().isNotEmpty) {
                            final updatedItem = item.copyWith(name: text.trim());
                            provider.updateItem(item.id, updatedItem);
                          }
                        },
                        onEditDetails: () => _showEditItemSheet(context, provider, item),
                        onDelete: () => _deleteItem(context, provider, item.id),
                        onToggleDone: () => provider.toggleItemDone(item.id),
                        onSubmitted: () => _addNewItem(provider, index + 1),
                      );
                    },
                  ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSuggestionsSheet(context, provider),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Suggestions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: selectedList.items.any((item) => item.done)
                        ? () => _completeTrip(context, provider)
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Complete Trip'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewItem(provider, selectedList.items.length),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addNewItem(GroceryProvider provider, int position) async {
    final newItem = GroceryItem(
      id: const Uuid().v4(),
      name: '',
    );
    await provider.addItem(newItem);
  }

  Future<void> _showEditItemSheet(BuildContext context, GroceryProvider provider, GroceryItem item) async {
    final result = await showModalBottomSheet<GroceryItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditItemSheet(item: item),
    );

    if (result != null) {
      await provider.updateItem(item.id, result);
    }
  }

  Future<void> _deleteItem(BuildContext context, GroceryProvider provider, String itemId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await provider.deleteItem(itemId);
    }
  }

  Future<void> _completeTrip(BuildContext context, GroceryProvider provider) async {
    final selectedList = provider.selectedList;
    if (selectedList == null) return;

    final checkedCount = selectedList.items.where((item) => item.done).length;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Shopping Trip'),
        content: Text(
          'This will remove $checkedCount checked item${checkedCount != 1 ? 's' : ''} '
          'and add them to your purchase history for predictions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await provider.completeShopping();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Shopping trip completed!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 95,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    }
  }

  void _showSuggestionsSheet(BuildContext context, GroceryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SuggestionsSheet(
        onItemAdded: (itemName) {
          _showOverlayNotification(context, itemName);
        },
      ),
    );
  }

  void _showOverlayNotification(BuildContext context, String itemName) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added $itemName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }
}
