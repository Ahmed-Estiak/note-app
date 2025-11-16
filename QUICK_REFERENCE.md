# Autonotic - Quick Reference Card

## 🚀 Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run -d chrome
```

## 📂 Project Structure

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # App configuration
├── models/                        # Data structures
│   ├── grocery_item.dart         # Item: name, price, category, expiry
│   ├── grocery_list.dart         # List: name, items[]
│   └── purchase.dart             # Purchase: itemName, boughtAt
├── providers/
│   └── grocery_provider.dart     # All business logic & state
├── pages/
│   ├── main_shell.dart           # Bottom navigation
│   ├── lists_page.dart           # Main grocery list UI
│   └── dashboard_page.dart       # Expense tracking
└── widgets/
    ├── add_edit_item_sheet.dart  # Add/edit item form
    ├── suggestions_sheet.dart    # AI predictions
    ├── expiring_banner.dart      # Expiry warnings
    └── list_selector.dart        # List dropdown
```

## 🔧 Key Components

### GroceryProvider (State Management)
```dart
// Lists
selectList(listId)
createList(name)
deleteList(listId)

// Items
addItem(item)
updateItem(itemId, item)
deleteItem(itemId)
toggleItemDone(itemId)

// Shopping
completeShopping()              // Move checked items to history

// Predictions
predictedItemNames(limit: 8)   // frequency × recency

// Expenses
getTotalSpentThisMonth()
getSpendingByCategory()

// Expiry
expiringSoonItems               // Items expiring within 3 days
```

### GroceryItem Model
```dart
GroceryItem(
  id: String,              // UUID
  name: String,            // Required
  price: double?,          // Optional
  category: String,        // Default: 'Other'
  expiry: DateTime?,       // Optional
  done: bool,              // Default: false
)

// Helpers
item.isExpiringSoon  // true if expires within 3 days
item.isExpired       // true if past expiry
```

## 🎨 UI Components

### Lists Page
- **List Selector**: Dropdown to switch lists, create/delete
- **Expiring Banner**: Shows items expiring soon (orange card)
- **Items List**: Checkboxes, names, prices, categories, expiry dates
- **FAB**: Add new item
- **Suggestions Button**: Show AI predictions
- **Complete Trip Button**: Finish shopping, update history

### Dashboard Page
- **Total Spent**: Big card with monthly total
- **Category Breakdown**: Cards with amounts and percentages
- **Progress Bars**: Visual spending distribution

### Bottom Sheets
- **Add/Edit Item**: Form with name, price, category, expiry
- **Suggestions**: List of predicted items with add buttons

## 📊 Categories

1. Fruits & Vegetables 🥬
2. Dairy 🥛
3. Meat & Seafood 🍖
4. Bakery 🍞
5. Beverages ☕
6. Snacks 🍪
7. Household 🏠
8. Other 📦

## 🔮 Prediction Algorithm

```
Score = Frequency × Recency

Frequency = Number of times purchased
Recency = 1 / (days since last purchase + 1)

Top 8 items by score (excluding items already in list)
```

## 💾 Data Storage

**SharedPreferences** (Browser Local Storage)
- `lists`: JSON array of all grocery lists
- `purchase_history`: JSON array of all purchases
- `selected_list_id`: Currently selected list ID

## 🎯 User Flow

### Adding Items
1. Click FAB (+)
2. Fill form (name required)
3. Click Add
4. Item appears in list

### Shopping Trip
1. Check off items as you shop
2. Click "Complete Trip"
3. Checked items removed
4. Purchase history updated
5. Predictions improve

### Getting Suggestions
1. Click "Suggestions" button
2. View predicted items
3. Click + to add to list
4. Item added instantly

### Tracking Expenses
1. Add prices when creating items
2. Complete shopping trips
3. Switch to Dashboard tab
4. View totals and breakdowns

## 🛠️ Common Tasks

### Change Theme Color
```dart
// lib/app.dart
colorSchemeSeed: Colors.green,  // Change to any color
```

### Add Category
```dart
// lib/widgets/add_edit_item_sheet.dart
final List<String> _categories = [
  'Your New Category',
  // ... existing categories
];
```

### Adjust Expiry Warning Days
```dart
// lib/models/grocery_item.dart
return difference.inDays >= 0 && difference.inDays <= 3;  // Change 3
```

### Change Prediction Limit
```dart
// lib/providers/grocery_provider.dart
List<String> predictedItemNames({int limit = 8})  // Change 8
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| App won't run | `flutter clean && flutter pub get` |
| Chrome not found | `flutter config --enable-web` |
| Data not saving | Check browser storage settings |
| Hot reload not working | Press `r` in terminal |
| Build errors | `flutter doctor` to check setup |

## ⌨️ Keyboard Shortcuts (Development)

- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit
- `h` - Help
- `c` - Clear screen

## 📱 Testing Tips

1. **Test on mobile size**: Chrome DevTools > Toggle device toolbar (Ctrl+Shift+M)
2. **Clear data**: DevTools > Application > Storage > Clear site data
3. **Check console**: F12 for errors and logs
4. **Test offline**: DevTools > Network > Offline

## 🚢 Deployment

### Build
```bash
flutter build web
```

### Deploy Options
- **Firebase**: `firebase deploy`
- **Netlify**: Drag `build/web` folder
- **GitHub Pages**: Copy `build/web/*` to repo
- **Vercel**: Import project, set build command

## 📈 Performance Tips

1. Run in release mode: `flutter run -d chrome --release`
2. Use const constructors where possible
3. Avoid rebuilding entire widget tree
4. Use `const` for static widgets

## 🔐 Data Privacy

- All data stored locally in browser
- No external API calls
- No user tracking
- No data collection
- Clear browser data to reset

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material 3 Design](https://m3.material.io/)
- [Dart Language](https://dart.dev/)

## 💡 Pro Tips

1. Complete 3-4 shopping trips to get good predictions
2. Add prices for accurate expense tracking
3. Set expiry dates for perishables
4. Use categories consistently for better insights
5. Create separate lists for different stores
6. Check suggestions before shopping

---

**Quick Help**: Press F12 in Chrome to open DevTools for debugging

**Need More Info?**: See README.md for full documentation

