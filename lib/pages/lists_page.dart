import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';
import '../widgets/list_selector.dart';
import '../widgets/note_card.dart';
import 'note_detail_page.dart';

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

    final notes = provider.getNotesForList(selectedList.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonotic'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List selector
          const ListSelector(),
          
          // Notes grid
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create a note',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailPage(noteId: note.id),
                            ),
                          );
                        },
                        onLongPress: () => _showDeleteNoteDialog(context, provider, note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewNote(context, provider, selectedList.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewNote(BuildContext context, GroceryProvider provider, String listId) async {
    final noteId = await provider.createNote(listId);
    if (noteId.isNotEmpty && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailPage(noteId: noteId),
        ),
      );
    }
  }

  Future<void> _showDeleteNoteDialog(BuildContext context, GroceryProvider provider, String noteId) async {
    final note = provider.getNote(noteId);
    if (note == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
          'Are you sure you want to delete "${note.title.isEmpty ? 'Untitled Note' : note.title}"?',
        ),
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
      await provider.deleteNote(noteId);
    }
  }
}
