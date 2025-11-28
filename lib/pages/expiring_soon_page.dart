import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grocery_item.dart';

class ExpiringSoonPage extends StatelessWidget {
  final List<GroceryItem> expiringItems;

  const ExpiringSoonPage({
    super.key,
    required this.expiringItems,
  });

  String _getExpiryText(GroceryItem item) {
    if (item.expiry == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(item.expiry!.year, item.expiry!.month, item.expiry!.day);
    final daysUntilExpiry = expiryDate.difference(today).inDays;
    
    if (daysUntilExpiry == 0) {
      return 'Today';
    } else if (daysUntilExpiry == 1) {
      return 'Tomorrow';
    } else {
      return 'in $daysUntilExpiry days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expiring Soon',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        toolbarHeight: 36,
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      body: expiringItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items expiring soon',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(11),
              itemCount: expiringItems.length,
              itemBuilder: (context, index) {
                final item = expiringItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(11),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          _getExpiryText(item),
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

