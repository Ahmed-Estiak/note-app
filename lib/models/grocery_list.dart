import 'note.dart';

class GroceryList {
  final String id;
  final String name;
  final List<Note> notes;

  GroceryList({
    required this.id,
    required this.name,
    List<Note>? notes,
  }) : notes = notes ?? [];

  GroceryList copyWith({
    String? id,
    String? name,
    List<Note>? notes,
  }) {
    return GroceryList(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: (json['notes'] as List<dynamic>?)
          ?.map((note) => Note.fromJson(note as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

