import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../models/grocery_list.dart';
import '../widgets/list_selector.dart';
import '../widgets/bullet_item.dart';
import '../widgets/add_edit_item_sheet.dart';
import '../widgets/suggestions_sheet.dart';
import '../widgets/magic_list_sheet.dart';
import '../widgets/expiring_banner.dart';
import '../utils/item_parser.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  // Map to store focus nodes for each item
  final Map<String, FocusNode> _focusNodes = {};
  final ScrollController _scrollController = ScrollController();
  String? _previousListId;
  final Set<String> _deletedMagicListSuggestions = {};
  final Map<String, String> _editedMagicListNames = {};

  @override
  void dispose() {
    // Dispose all focus nodes
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  FocusNode _getFocusNode(String itemId) {
    return _focusNodes.putIfAbsent(itemId, () => FocusNode());
  }

  void _focusLastEmptyBullet(GroceryProvider provider) {
    final selectedList = provider.selectedList;
    if (selectedList == null || selectedList.items.isEmpty) return;

    // Find the last empty bullet
    for (int i = selectedList.items.length - 1; i >= 0; i--) {
      if (selectedList.items[i].name.trim().isEmpty) {
        final itemId = selectedList.items[i].id;
        final focusNode = _getFocusNode(itemId);
        
        // Request focus after a short delay to ensure UI is updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            focusNode.requestFocus();
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final selectedList = provider.selectedList;

    if (selectedList == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Detect category change and scroll to bottom
    if (_previousListId != selectedList.id) {
      _previousListId = selectedList.id;
      _scrollToBottom();
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: selectedList.items.length,
              itemBuilder: (context, index) {
                final item = selectedList.items[index];
                final isLastItem = index == selectedList.items.length - 1;
                
                return BulletItem(
                  key: ValueKey(item.id),
                  item: item,
                  focusNode: _getFocusNode(item.id),
                  autoFocus: isLastItem && item.name.isEmpty,
                  onTextChanged: (text) {
                    if (text.trim().isNotEmpty) {
                      // Parse the text for quantity and price
                      final parsed = ItemParser.parse(text);
                      
                      if (parsed.isValid) {
                        final updatedItem = item.copyWith(
                          name: parsed.name,
                          quantity: parsed.quantity,
                          price: parsed.price,
                          clearQuantity: parsed.quantity == null,
                          clearPrice: parsed.price == null,
                        );
                        provider.updateItem(item.id, updatedItem);
                      }
                    }
                  },
                  onEditDetails: () => _showEditItemSheet(context, provider, item),
                  onDelete: () => _deleteItem(context, provider, item.id),
                  onToggleDone: () => provider.toggleItemDone(item.id),
                  onEmptySubmitted: () {
                    // Empty bullet + Enter: jump to last empty bullet
                    _focusLastEmptyBullet(provider);
                  },
                  onTextDeleted: () {
                    // Not used anymore - no auto-delete on text removal
                  },
                  onSubmitted: (text) {
                    // Parse to check validity
                    final parsed = ItemParser.parse(text);
                    
                    if (!parsed.isValid) {
                      // Invalid (e.g., "# 12pcs" with no name): keep empty and refocus
                      return;
                    }
                    
                    if (isLastItem) {
                      // Last item: add new bullet if it has content
                      if (text.trim().isNotEmpty) {
                        _addNewItemIfNeeded(provider);
                      }
                    } else {
                      // Not last item: save and jump to last empty bullet
                      _focusLastEmptyBullet(provider);
                    }
                  },
                  onFocusLost: (text) {
                    // Parse to check validity
                    final parsed = ItemParser.parse(text);
                    
                    if (!parsed.isValid) {
                      // Invalid: don't add new bullet
                      return;
                    }
                    
                    // Also add new bullet when focus is lost on the last item with content
                    if (isLastItem && text.trim().isNotEmpty) {
                      _addNewItemIfNeeded(provider);
                    }
                  },
                );
              },
            ),
          ),

          // Quick suggestions
          _buildQuickSuggestions(context, provider, selectedList),

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
                    onPressed: () => _showMagicListSheet(context, provider),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Magic List'),
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
    );
  }

  Widget _buildQuickSuggestions(BuildContext context, GroceryProvider provider, GroceryList selectedList) {
    // Get top 8 suggestions
    final suggestions = provider.predictedItemNames(limit: 8);
    
    // Filter out items already in the list
    final existingItemNames = selectedList.items
        .map((item) => item.name.toLowerCase().trim())
        .toSet();
    
    final filteredSuggestions = suggestions
        .where((suggestion) => !existingItemNames.contains(suggestion))
        .toList();
    
    // Don't show section if no suggestions
    if (filteredSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filteredSuggestions.map((suggestion) {
          // Use edited name if available, otherwise capitalize original
          final editedName = _editedMagicListNames[suggestion];
          final displayName = editedName ?? (suggestion[0].toUpperCase() + suggestion.substring(1));
          
          return ActionChip(
            label: Text(displayName),
            onPressed: () => _addQuickSuggestion(context, provider, displayName),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _addQuickSuggestion(BuildContext context, GroceryProvider provider, String itemName) async {
    final selectedList = provider.selectedList;
    if (selectedList == null) return;
    
    // Parse the item name for quantity and price
    final parsed = ItemParser.parse(itemName);
    
    // Try to find existing itemId for this suggestion (to preserve history)
    // Use the parsed name for lookup
    final existingItemId = provider.getItemIdForSuggestion(parsed.name);
    
    final newItem = GroceryItem(
      id: existingItemId ?? const Uuid().v4(),
      name: parsed.name,
      quantity: parsed.quantity,
      price: parsed.price,
    );
    
    // Find the last empty bullet point
    int? emptyBulletIndex;
    for (int i = selectedList.items.length - 1; i >= 0; i--) {
      if (selectedList.items[i].name.trim().isEmpty) {
        emptyBulletIndex = i;
        break;
      }
    }
    
    // Insert before the empty bullet if it exists, otherwise append
    if (emptyBulletIndex != null) {
      await provider.addItem(newItem, position: emptyBulletIndex);
    } else {
      await provider.addItem(newItem);
    }
    
    // Show overlay notification
    _showOverlayNotification(context, itemName);
  }

  Future<void> _addNewItem(GroceryProvider provider, int position) async {
    final newItem = GroceryItem(
      id: const Uuid().v4(),
      name: '',
    );
    await provider.addItem(newItem);
  }

  Future<void> _addNewItemIfNeeded(GroceryProvider provider) async {
    final selectedList = provider.selectedList;
    if (selectedList == null) return;
    
    // Check if the last item is already empty
    if (selectedList.items.isNotEmpty) {
      final lastItem = selectedList.items.last;
      if (lastItem.name.trim().isEmpty) {
        // Already have an empty bullet, don't add another
        return;
      }
    }
    
    // Add new empty bullet
    await _addNewItem(provider, selectedList.items.length);
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
        _showOverlayNotification(context, 'Shopping trip completed!');
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

  void _showMagicListSheet(BuildContext context, GroceryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => MagicListSheet(
        deletedSuggestions: _deletedMagicListSuggestions,
        editedNames: _editedMagicListNames,
        onDelete: (suggestion) {
          setState(() {
            _deletedMagicListSuggestions.add(suggestion);
          });
        },
        onNameEdited: (originalName, editedName) async {
          // Parse the edited name to extract clean item name (without #qty *price)
          final parsed = ItemParser.parse(editedName);
          
          print('DEBUG onNameEdited: original="$originalName", edited="$editedName", parsed="${parsed.name}"');
          
          // Store FULL text (with symbols) in local map for UI display
          setState(() {
            _editedMagicListNames[originalName] = editedName;
          });
          
          // Update purchase history with ONLY the parsed name (clean item name)
          // This ensures suggestions show "beef" not "beef #4"
          await provider.updatePurchaseHistoryByName(
            originalName,
            parsed.name,
            listId: provider.selectedList?.id,
          );
        },
        onAddAll: (items) async {
          final selectedList = provider.selectedList;
          if (selectedList == null) return;

          // Find the last empty bullet point
          int? emptyBulletIndex;
          for (int i = selectedList.items.length - 1; i >= 0; i--) {
            if (selectedList.items[i].name.trim().isEmpty) {
              emptyBulletIndex = i;
              break;
            }
          }

          // Add all items before the empty bullet
          for (final itemName in items) {
            // Parse the item name for quantity and price
            final parsed = ItemParser.parse(itemName);
            
            print('DEBUG onAddAll: itemName="$itemName", parsed="${parsed.name}", qty="${parsed.quantity}", price="${parsed.price}"');
            
            // Try to find existing itemId for this item (to preserve history)
            // Use the parsed name for lookup
            final existingItemId = provider.getItemIdForSuggestion(parsed.name);
            
            final newItem = GroceryItem(
              id: existingItemId ?? const Uuid().v4(),
              name: parsed.name,
              quantity: parsed.quantity,
              price: parsed.price,
            );
            
            if (emptyBulletIndex != null) {
              await provider.addItem(newItem, position: emptyBulletIndex);
              emptyBulletIndex++; // Increment for next item
            } else {
              await provider.addItem(newItem);
            }
          }

          // Clear deleted suggestions and edited names after successful add
          setState(() {
            _deletedMagicListSuggestions.clear();
            _editedMagicListNames.clear();
          });

          // Show notification
          if (context.mounted) {
            _showOverlayNotification(context, '${items.length} items added');
          }
        },
      ),
    );
  }

  void _showOverlayNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    // Determine if this is a "Shopping trip completed" message or item added
    final isCompletedMessage = message.contains('completed');
    final displayText = isCompletedMessage ? message : 'Added $message';
    final icon = isCompletedMessage ? Icons.shopping_bag : Icons.check_circle;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
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
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayText,
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
