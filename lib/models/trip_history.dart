class TripHistory {
  final String id;
  final DateTime completedAt;
  final String listName; // Category name
  final String listId;
  final List<TripItem> items; // Items purchased in this trip

  TripHistory({
    required this.id,
    required this.completedAt,
    required this.listName,
    required this.listId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'listName': listName,
      'listId': listId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    return TripHistory(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      listName: json['listName'] as String,
      listId: json['listId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => TripItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TripItem {
  final String name;
  final String? quantity;
  final double? price;

  TripItem({
    required this.name,
    this.quantity,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem(
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }
}

