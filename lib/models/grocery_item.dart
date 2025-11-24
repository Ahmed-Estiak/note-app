class GroceryItem {
  final String id;
  final String name;
  final String? quantity; // e.g., "10pcs", "2kg", "5L" - max 20 chars
  final double? price;
  final String category;
  final DateTime? expiry;
  final bool done;

  GroceryItem({
    required this.id,
    required this.name,
    this.quantity,
    this.price,
    this.category = 'Other',
    this.expiry,
    this.done = false,
  });

  // Check if item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiry == null) return false;
    // Compare dates only (ignore time)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(expiry!.year, expiry!.month, expiry!.day);
    final difference = expiryDate.difference(today);
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
    String? quantity,
    double? price,
    String? category,
    DateTime? expiry,
    bool? done,
    bool clearQuantity = false,
    bool clearPrice = false,
    bool clearExpiry = false,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: clearQuantity ? null : (quantity ?? this.quantity),
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
      'quantity': quantity,
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
      quantity: json['quantity'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String? ?? 'Other',
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry'] as String) : null,
      done: json['done'] as bool? ?? false,
    );
  }
}

