import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';

class MagicListSheet extends StatefulWidget {
  final Function(List<String> items) onAddAll;

  const MagicListSheet({
    super.key,
    required this.onAddAll,
  });

  @override
  State<MagicListSheet> createState() => _MagicListSheetState();
}

class _MagicListSheetState extends State<MagicListSheet> {
  final List<TextEditingController> _controllers = [];
  final List<bool> _deletedItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize with 5 empty controllers and deletion states
    for (int i = 0; i < 5; i++) {
      _controllers.add(TextEditingController());
      _deletedItems.add(false);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _deleteItem(int index) {
    setState(() {
      _deletedItems[index] = true;
    });
  }

  void _addAllItems() {
    final items = <String>[];
    for (int i = 0; i < _controllers.length; i++) {
      if (!_deletedItems[i]) {
        final text = _controllers[i].text.trim();
        if (text.isNotEmpty) {
          items.add(text);
        }
      }
    }
    
    if (items.isNotEmpty) {
      widget.onAddAll(items);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final selectedList = provider.selectedList;

    // Get suggestions and populate controllers on first build
    if (_controllers[0].text.isEmpty) {
      final suggestions = provider.predictedItemNames(limit: 5);
      
      // Filter out items already in the list
      final existingItemNames = selectedList?.items
          .map((item) => item.name.toLowerCase().trim())
          .toSet() ?? {};
      
      final filteredSuggestions = suggestions
          .where((suggestion) => !existingItemNames.contains(suggestion))
          .take(5)
          .toList();
      
      // Populate controllers with suggestions
      for (int i = 0; i < filteredSuggestions.length && i < 5; i++) {
        _controllers[i].text = filteredSuggestions[i][0].toUpperCase() + 
                                filteredSuggestions[i].substring(1);
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Magic List',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5 Editable boxes
          ...List.generate(5, (index) {
            if (_deletedItems[index]) {
              return const SizedBox.shrink();
            }
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          hintText: 'Item ${index + 1}',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteItem(index),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Add All button
          FilledButton.icon(
            onPressed: _addAllItems,
            icon: const Icon(Icons.add_circle),
            label: const Text('Add All'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 8),

          // Close button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

