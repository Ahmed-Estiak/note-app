import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../providers/grocery_provider.dart';

class SuggestionsSheet extends StatelessWidget {
  final Function(String itemName)? onItemAdded;
  
  const SuggestionsSheet({
    super.key,
    this.onItemAdded,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final suggestions = provider.predictedItemNames(limit: 8);
    
    // Filter out items already in selected list
    final selectedList = provider.selectedList;
    final existingItemNames = selectedList?.items
        .map((item) => item.name.toLowerCase().trim())
        .toSet() ?? {};
    
    final filteredSuggestions = suggestions
        .where((suggestion) => !existingItemNames.contains(suggestion))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Suggested Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your purchase history',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          
          if (filteredSuggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No suggestions yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a shopping trip to build your purchase history',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                final itemName = filteredSuggestions[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.add_shopping_cart),
                    title: Text(
                      // Capitalize first letter
                      itemName[0].toUpperCase() + itemName.substring(1),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        final selectedList = provider.selectedList;
                        if (selectedList == null) return;
                        
                        // Add suggested item to selected list
                        final newItem = GroceryItem(
                          id: const Uuid().v4(),
                          name: itemName[0].toUpperCase() + itemName.substring(1),
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
                        
                        // Call the callback to show snackbar in parent context
                        onItemAdded?.call(newItem.name);
                      },
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

