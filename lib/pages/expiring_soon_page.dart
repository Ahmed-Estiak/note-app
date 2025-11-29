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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.orange.shade200,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Expiring Soon',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${expiringItems.length} ${expiringItems.length == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      Divider(
                        color: Colors.orange.shade200,
                        thickness: 1,
                      ),
                      const SizedBox(height: 12),
                      // Items list
                      ...expiringItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == expiringItems.length - 1;
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bullet point
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Item name and details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (item.quantity != null || item.category != 'Other') ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        [
                                          if (item.quantity != null) 'Qty: ${item.quantity}',
                                          if (item.category != 'Other') item.category,
                                        ].join(' • '),
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Expiry text
                              Text(
                                _getExpiryText(item),
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

