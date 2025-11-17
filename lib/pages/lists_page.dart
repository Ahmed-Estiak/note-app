import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../widgets/list_selector.dart';
import '../widgets/expiring_banner.dart';
import '../widgets/add_edit_item_sheet.dart';
import '../widgets/suggestions_sheet.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final selectedList = provider.selectedList;
    final expiringItems = provider.expiringSoonItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonotic'),
        centerTitle: true,
      ),
      body: selectedList == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // List selector
                const ListSelector(),
                
                // Expiring soon banner
                ExpiringBanner(expiringItems: expiringItems),
                
                // Items list
                Expanded(
                  child: selectedList.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 80,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add items',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                            return _ItemTile(item: item);
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
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (sheetContext) => SuggestionsSheet(
                                onItemAdded: (itemName) {
                                  // Show overlay notification (appears on top of everything)
                                  _showOverlayNotification(context, itemName);
                                },
                              ),
                            );
                          },
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
        onPressed: () => _showAddItemSheet(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemSheet(BuildContext context, GroceryProvider provider) async {
    final result = await showModalBottomSheet<GroceryItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddEditItemSheet(),
    );

    if (result != null) {
      await provider.addItem(result);
    }
  }

  Future<void> _completeTrip(BuildContext context, GroceryProvider provider) async {
    final checkedCount = provider.selectedList?.items.where((item) => item.done).length ?? 0;
    
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
              bottom: 75,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    }
  }

  void _showOverlayNotification(BuildContext context, String itemName) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        //top: MediaQuery.of(context).padding.top + 80,
        
        top: MediaQuery.of(context).size.height * 0.93,  // Position 30% from the top
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      overlayEntry.remove();
    });
  }
}

class _ItemTile extends StatelessWidget {
  final GroceryItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GroceryProvider>();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.done,
          onChanged: (value) {
            provider.toggleItemDone(item.id);
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.done ? TextDecoration.lineThrough : null,
            color: item.done 
                ? Theme.of(context).colorScheme.outline 
                : null,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditItemSheet(context, provider),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteItem(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    
    if (item.price != null) {
      parts.add('\$${item.price!.toStringAsFixed(2)}');
    }
    
    parts.add(item.category);
    
    if (item.expiry != null) {
      final expiryText = DateFormat('MMM dd').format(item.expiry!);
      parts.add('Exp: $expiryText');
    }
    
    if (parts.isEmpty) return null;
    
    return Text(
      parts.join(' • '),
      style: TextStyle(
        color: item.isExpiringSoon 
            ? Colors.orange.shade700 
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: item.isExpiringSoon ? FontWeight.w500 : null,
      ),
    );
  }

  Future<void> _showEditItemSheet(BuildContext context, GroceryProvider provider) async {
    final result = await showModalBottomSheet<GroceryItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditItemSheet(item: item),
    );

    if (result != null) {
      await provider.updateItem(item.id, result);
    }
  }

  Future<void> _deleteItem(BuildContext context, GroceryProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
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
      await provider.deleteItem(item.id);
    }
  }
}

