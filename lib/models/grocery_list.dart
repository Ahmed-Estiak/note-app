import 'grocery_item.dart';

class GroceryList {
  final String id;
  final String name;
  final List<GroceryItem> items;

  GroceryList({
    required this.id,
    required this.name,
    List<GroceryItem>? items,
  }) : items = items ?? [];

  GroceryList copyWith({
    String? id,
    String? name,
    List<GroceryItem>? items,
  }) {
    return GroceryList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

