import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/grocery_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final totalSpent = provider.getTotalSpentThisMonth();
    final categoryTotals = provider.getSpendingByCategory();
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Dashboard',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        toolbarHeight: 26,
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month header
            Text(
              monthName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 17),
            
            // Total spent card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 34,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'Total Spent',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${totalSpent.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 17),
            
            // Category breakdown
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 11),
            
            if (categoryTotals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 45,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 11),
                      Text(
                        'No expenses yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complete shopping trips with priced items to see your spending breakdown',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...categoryTotals.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage = totalSpent > 0 
                    ? (amount / totalSpent * 100) 
                    : 0.0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            Text(
                              '\$${amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            
            const SizedBox(height: 11),
            
            // Info card
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add prices to items and complete shopping trips to track your expenses',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fruits & Vegetables':
        return Icons.eco;
      case 'Dairy':
        return Icons.water_drop;
      case 'Meat & Seafood':
        return Icons.set_meal;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Beverages':
        return Icons.local_cafe;
      case 'Snacks':
        return Icons.cookie;
      case 'Household':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}

