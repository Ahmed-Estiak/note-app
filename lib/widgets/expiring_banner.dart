import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class ExpiringBanner extends StatelessWidget {
  final List<GroceryItem> expiringItems;
  final VoidCallback? onTap;

  const ExpiringBanner({
    super.key,
    required this.expiringItems,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expiringItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Expiring soon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${expiringItems.length} item${expiringItems.length != 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

