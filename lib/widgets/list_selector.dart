import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';

class ListSelector extends StatelessWidget {
  const ListSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final lists = provider.lists;
    final selectedList = provider.selectedList;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Row(
          children: [
            const Icon(Icons.list_alt, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedList?.id,
                  isExpanded: true,
                  items: lists.map((list) {
                    return DropdownMenuItem(
                      value: list.id,
                      child: Text(
                        list.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (listId) {
                    if (listId != null) {
                      provider.selectList(listId);
                    }
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              tooltip: 'Rename list',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () => _showRenameListDialog(context, provider),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              tooltip: 'Create new list',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () => _showCreateListDialog(context, provider),
            ),
            if (lists.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                tooltip: 'Delete list',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteListDialog(context, provider),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context, GroceryProvider provider) async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'List Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await provider.createList(controller.text.trim());
    }
    
    controller.dispose();
  }

  Future<void> _showRenameListDialog(BuildContext context, GroceryProvider provider) async {
    final selectedList = provider.selectedList;
    if (selectedList == null) return;

    final controller = TextEditingController(text: selectedList.name);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'List Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await provider.renameList(selectedList.id, controller.text.trim());
    }
    
    controller.dispose();
  }

  Future<void> _showDeleteListDialog(BuildContext context, GroceryProvider provider) async {
    final selectedList = provider.selectedList;
    if (selectedList == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${selectedList.name}"?'),
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
      await provider.deleteList(selectedList.id);
    }
  }
}

