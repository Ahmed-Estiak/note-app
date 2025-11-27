class ParsedItem {
  final String name;
  final String? quantity;
  final double? price;
  final bool isValid;
  final bool hasQuantitySymbol;
  final bool hasPriceSymbol;

  ParsedItem({
    required this.name,
    this.quantity,
    this.price,
    required this.isValid,
    this.hasQuantitySymbol = false,
    this.hasPriceSymbol = false,
  });

  ParsedItem.invalid()
      : name = '',
        quantity = null,
        price = null,
        isValid = false,
        hasQuantitySymbol = false,
        hasPriceSymbol = false;
}

class ItemParser {
  /// Parse item name with optional quantity (#) and price (*) symbols
  /// 
  /// Supports flexible ordering:
  /// - "eggs # 12pcs * 5.99"
  /// - "milk * 3.50 dollars # 2L"
  /// - "bread * 2.99"
  /// - "apples # 1kg"
  /// 
  /// Returns invalid if name is empty before symbols
  static ParsedItem parse(String input) {
    final trimmed = input.trim();
    
    if (trimmed.isEmpty) {
      return ParsedItem.invalid();
    }

    // Find positions of # and * symbols
    final hashIndex = trimmed.indexOf('#');
    final asteriskIndex = trimmed.indexOf('*');

    // If no symbols, return the whole string as name
    if (hashIndex == -1 && asteriskIndex == -1) {
      return ParsedItem(
        name: trimmed,
        isValid: true,
        hasQuantitySymbol: false,
        hasPriceSymbol: false,
      );
    }

    // Find the first symbol position
    int firstSymbolIndex = -1;
    if (hashIndex != -1 && asteriskIndex != -1) {
      firstSymbolIndex = hashIndex < asteriskIndex ? hashIndex : asteriskIndex;
    } else if (hashIndex != -1) {
      firstSymbolIndex = hashIndex;
    } else {
      firstSymbolIndex = asteriskIndex;
    }

    // Extract name (everything before first symbol)
    final name = trimmed.substring(0, firstSymbolIndex).trim();
    
    // Validate: name must not be empty
    if (name.isEmpty) {
      return ParsedItem.invalid();
    }

    // Extract quantity and price based on symbol positions
    String? quantity;
    double? price;

    if (hashIndex != -1 && asteriskIndex != -1) {
      // Both symbols present
      if (hashIndex < asteriskIndex) {
        // Order: name # quantity * price
        quantity = _extractQuantity(trimmed, hashIndex, asteriskIndex);
        price = _extractPrice(trimmed, asteriskIndex, trimmed.length);
      } else {
        // Order: name * price # quantity
        price = _extractPrice(trimmed, asteriskIndex, hashIndex);
        quantity = _extractQuantity(trimmed, hashIndex, trimmed.length);
      }
    } else if (hashIndex != -1) {
      // Only # present
      quantity = _extractQuantity(trimmed, hashIndex, trimmed.length);
    } else if (asteriskIndex != -1) {
      // Only * present
      price = _extractPrice(trimmed, asteriskIndex, trimmed.length);
    }

    return ParsedItem(
      name: name,
      quantity: quantity,
      price: price,
      isValid: true,
      hasQuantitySymbol: hashIndex != -1,
      hasPriceSymbol: asteriskIndex != -1,
    );
  }

  /// Extract quantity text between # and next symbol (or end)
  static String? _extractQuantity(String text, int startIndex, int endIndex) {
    if (startIndex == -1 || startIndex >= text.length - 1) return null;
    
    final quantityText = text.substring(startIndex + 1, endIndex).trim();
    
    // Limit to 20 characters
    if (quantityText.isEmpty) return null;
    if (quantityText.length > 20) {
      return quantityText.substring(0, 20);
    }
    
    return quantityText;
  }

  /// Extract price (numbers only) between * and next symbol (or end)
  static double? _extractPrice(String text, int startIndex, int endIndex) {
    if (startIndex == -1 || startIndex >= text.length - 1) return null;
    
    final priceText = text.substring(startIndex + 1, endIndex).trim();
    if (priceText.isEmpty) return null;

    // Extract only numbers and decimal point using regex
    final numberRegex = RegExp(r'\d+\.?\d{0,2}');
    final match = numberRegex.firstMatch(priceText);
    
    if (match == null) return null;
    
    final numberString = match.group(0);
    return double.tryParse(numberString ?? '');
  }
}

