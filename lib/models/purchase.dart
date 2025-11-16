class Purchase {
  final String itemName;
  final DateTime boughtAt;

  Purchase({
    required this.itemName,
    required this.boughtAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'boughtAt': boughtAt.toIso8601String(),
    };
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      itemName: json['itemName'] as String,
      boughtAt: DateTime.parse(json['boughtAt'] as String),
    );
  }
}

