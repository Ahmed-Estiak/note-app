import 'grocery_item.dart';

class Note {
  final String id;
  final String title;
  final String categoryId;
  final List<GroceryItem> items;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.categoryId,
    List<GroceryItem>? items,
    DateTime? createdAt,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    String? categoryId,
    List<GroceryItem>? items,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      categoryId: json['categoryId'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

