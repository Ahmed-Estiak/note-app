class GroceryItem {
  final String id;
  final String name;
  final double? price;
  final String category;
  final DateTime? expiry;
  final bool done;

  GroceryItem({
    required this.id,
    required this.name,
    this.price,
    this.category = 'Other',
    this.expiry,
    this.done = false,
  });

  // Check if item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiry == null) return false;
    final now = DateTime.now();
    final difference = expiry!.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 3;
  }

  // Check if item is expired
  bool get isExpired {
    if (expiry == null) return false;
    return expiry!.isBefore(DateTime.now());
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    DateTime? expiry,
    bool? done,
    bool clearPrice = false,
    bool clearExpiry = false,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: clearPrice ? null : (price ?? this.price),
      category: category ?? this.category,
      expiry: clearExpiry ? null : (expiry ?? this.expiry),
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'expiry': expiry?.toIso8601String(),
      'done': done,
    };
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String? ?? 'Other',
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry'] as String) : null,
      done: json['done'] as bool? ?? false,
    );
  }
}

