import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../utils/item_parser.dart';

class MagicListSheet extends StatefulWidget {
  final Function(List<String> items) onAddAll;
  final Set<String> deletedSuggestions;
  final Map<String, String> editedNames;
  final Function(String suggestion) onDelete;
  final Function(String originalName, String editedName) onNameEdited;

  const MagicListSheet({
    super.key,
    required this.onAddAll,
    required this.deletedSuggestions,
    required this.editedNames,
    required this.onDelete,
    required this.onNameEdited,
  });

  @override
  State<MagicListSheet> createState() => _MagicListSheetState();
}

class _MagicListSheetState extends State<MagicListSheet> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<bool> _deletedItems = [];
  final List<String> _originalNames = []; // Track original suggestion names
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized dynamically based on available suggestions
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
  
  // Save edit when user presses Enter or loses focus
  void _saveEdit(int index) {
    if (index >= _controllers.length || _deletedItems[index]) return;
    
    final originalName = _originalNames[index];
    final currentText = _controllers[index].text.trim();
    final normalizedCurrent = currentText.toLowerCase();
    final normalizedOriginal = originalName.toLowerCase().trim();
    
    print('DEBUG _saveEdit: index=$index, originalName="$originalName", currentText="$currentText"');
    
    if (currentText.isEmpty) {
      // Empty text: revert to original name
      _controllers[index].text = originalName[0].toUpperCase() + originalName.substring(1);
      print('DEBUG _saveEdit: Empty text, reverted to original');
      return;
    }
    
    // Parse to check if name is valid
    final parsed = ItemParser.parse(currentText);
    
    if (!parsed.isValid) {
      // Invalid (e.g., only "# qty"): revert to original name
      _controllers[index].text = originalName[0].toUpperCase() + originalName.substring(1);
      print('DEBUG _saveEdit: Invalid parsed name, reverted to original');
      return;
    }
    
    // Valid: save the edit with original formatting
    if (normalizedCurrent != normalizedOriginal) {
      print('DEBUG _saveEdit: Saving edit - calling onNameEdited');
      widget.onNameEdited(originalName, currentText);
    } else {
      print('DEBUG _saveEdit: No change detected, not saving');
    }
  }

  void _deleteItem(int index) {
    if (index < _controllers.length) {
      final itemName = _controllers[index].text.trim().toLowerCase();
      widget.onDelete(itemName);
      setState(() {
        _deletedItems[index] = true;
      });
    }
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
    final provider = context.read<GroceryProvider>();
    final selectedList = provider.selectedList;

    // Initialize controllers dynamically based on available suggestions (only once)
    if (!_initialized) {
      final suggestions = provider.predictedItemNames(limit: 5);
      
      // Filter out items already in the list AND deleted suggestions
      final existingItemNames = selectedList?.items
          .map((item) => item.name.toLowerCase().trim())
          .toSet() ?? {};
      
      final filteredSuggestions = suggestions
          .where((suggestion) => 
              !existingItemNames.contains(suggestion) &&
              !widget.deletedSuggestions.contains(suggestion))
          .take(5)
          .toList();
      
      // Create controllers only for available suggestions
      for (int i = 0; i < filteredSuggestions.length; i++) {
        final originalName = filteredSuggestions[i];
        final capitalizedOriginal = originalName[0].toUpperCase() + originalName.substring(1);
        
        // Check if this suggestion has been edited before
        final displayName = widget.editedNames[originalName] ?? capitalizedOriginal;
        
        print('DEBUG init: index=$i, originalName="$originalName", displayName="$displayName"');
        
        final controller = TextEditingController(text: displayName);
        final focusNode = FocusNode();
        final controllerIndex = i; // Capture index for focus listener
        
        // Listen for focus changes - save when user taps outside
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            _saveEdit(controllerIndex);
          }
        });
        
        _controllers.add(controller);
        _focusNodes.add(focusNode);
        _deletedItems.add(false);
        _originalNames.add(originalName);
      }
      
      _initialized = true;
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

          // Dynamic editable boxes (only show available suggestions)
          ...List.generate(_controllers.length, (index) {
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
                        focusNode: _focusNodes[index],
                        decoration: InputDecoration(
                          hintText: 'Item ${index + 1}',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 16),
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          // Save on Enter key press
                          _saveEdit(index);
                        },
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

