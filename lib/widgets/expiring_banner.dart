import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';

class ExpiringBanner extends StatelessWidget {
  final List<GroceryItem> expiringItems;

  const ExpiringBanner({super.key, required this.expiringItems});

  @override
  Widget build(BuildContext context) {
    if (expiringItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expiring Soon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...expiringItems.map((item) {
              // Compare dates only (ignore time)
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final expiryDate = DateTime(item.expiry!.year, item.expiry!.month, item.expiry!.day);
              final daysUntilExpiry = expiryDate.difference(today).inDays;
              
              final expiryText = daysUntilExpiry == 0 
                  ? 'Today' 
                  : daysUntilExpiry == 1
                      ? 'Tomorrow'
                      : 'in $daysUntilExpiry days';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      expiryText,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

