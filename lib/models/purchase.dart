class Purchase {
  final String itemName;
  final String itemId;
  final String listId;
  final DateTime boughtAt;
  final double? price;
  final String category;

  Purchase({
    required this.itemName,
    required this.itemId,
    required this.listId,
    required this.boughtAt,
    this.price,
    this.category = 'Other',
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'itemId': itemId,
      'listId': listId,
      'boughtAt': boughtAt.toIso8601String(),
      'price': price,
      'category': category,
    };
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      itemName: json['itemName'] as String,
      itemId: json['itemId'] as String? ?? '', // Default for old data
      listId: json['listId'] as String? ?? '', // Default for old data
      boughtAt: DateTime.parse(json['boughtAt'] as String),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String? ?? 'Other',
    );
  }
}

