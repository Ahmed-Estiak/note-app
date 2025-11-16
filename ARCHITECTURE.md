# Autonotic - Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Interface                       │
│                     (Flutter Material 3)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Navigation Layer                        │
│                       (MainShell)                            │
│  ┌──────────────────────┐    ┌──────────────────────┐      │
│  │    Lists Page        │    │   Dashboard Page     │      │
│  │  (Grocery Lists)     │    │  (Expense Tracking)  │      │
│  └──────────────────────┘    └──────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    State Management Layer                    │
│                     (GroceryProvider)                        │
│  • List Management    • Item CRUD    • Predictions          │
│  • Shopping Trips     • Expenses     • Expiry Tracking      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│                   (SharedPreferences)                        │
│  • Lists Storage      • Purchase History    • Preferences   │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Component Hierarchy

```
main.dart
└── AutonoticApp (app.dart)
    └── MainShell (pages/main_shell.dart)
        ├── ListsPage (pages/lists_page.dart)
        │   ├── ListSelector (widgets/list_selector.dart)
        │   ├── ExpiringBanner (widgets/expiring_banner.dart)
        │   ├── ItemsList
        │   │   └── ItemTile (multiple)
        │   ├── AddEditItemSheet (widgets/add_edit_item_sheet.dart)
        │   └── SuggestionsSheet (widgets/suggestions_sheet.dart)
        │
        └── DashboardPage (pages/dashboard_page.dart)
            ├── TotalSpentCard
            └── CategoryBreakdownList
```

## 🔄 Data Flow

### Adding an Item
```
User Input (AddEditItemSheet)
    ↓
GroceryProvider.addItem()
    ↓
Update State (notifyListeners)
    ↓
Save to SharedPreferences
    ↓
UI Updates (Consumer/Watch)
```

### Completing Shopping Trip
```
User Clicks "Complete Trip"
    ↓
GroceryProvider.completeShopping()
    ↓
1. Get checked items
2. Add to purchase history
3. Remove from list
4. Save to storage
    ↓
notifyListeners()
    ↓
UI Updates + Snackbar
```

### Getting Predictions
```
User Clicks "Suggestions"
    ↓
GroceryProvider.predictedItemNames()
    ↓
1. Group purchases by item name
2. Calculate frequency (count)
3. Calculate recency (1/days)
4. Score = frequency × recency
5. Sort by score
6. Filter out existing items
7. Return top 8
    ↓
Display in SuggestionsSheet
```

## 🗂️ Data Models

### GroceryItem
```dart
{
  "id": "uuid-v4",
  "name": "Milk",
  "price": 3.99,
  "category": "Dairy",
  "expiry": "2024-11-20T00:00:00.000Z",
  "done": false
}
```

### GroceryList
```dart
{
  "id": "uuid-v4",
  "name": "Weekly",
  "items": [
    { /* GroceryItem */ },
    { /* GroceryItem */ }
  ]
}
```

### Purchase
```dart
{
  "itemName": "milk",
  "boughtAt": "2024-11-16T10:30:00.000Z"
}
```

## 🔌 Provider Pattern

### Provider Setup (main.dart)
```dart
ChangeNotifierProvider(
  create: (_) => GroceryProvider()..load(),
  child: AutonoticApp(),
)
```

### Consuming State (UI)
```dart
// Watch for changes (rebuilds on update)
final provider = context.watch<GroceryProvider>();

// Read once (no rebuild)
final provider = context.read<GroceryProvider>();

// Select specific value
final list = context.select((GroceryProvider p) => p.selectedList);
```

## 🎯 Key Design Patterns

### 1. Provider Pattern (State Management)
- Single source of truth
- Reactive UI updates
- Separation of concerns

### 2. Repository Pattern (Data Access)
- GroceryProvider handles all data operations
- SharedPreferences abstracted away
- Easy to swap storage backend

### 3. Model-View-ViewModel (MVVM)
- Models: Pure data classes
- Views: UI widgets
- ViewModel: GroceryProvider

### 4. Composition over Inheritance
- Small, reusable widgets
- Bottom sheets for forms
- Cards for content grouping

## 🔐 State Management Strategy

### Local State (StatefulWidget)
- Form inputs
- Animation controllers
- Temporary UI state

### Global State (Provider)
- Grocery lists
- Purchase history
- Selected list
- All business logic

## 💾 Persistence Strategy

### What's Stored
```
SharedPreferences Keys:
├── "lists"              → JSON array of GroceryList
├── "purchase_history"   → JSON array of Purchase
└── "selected_list_id"   → String (UUID)
```

### When Data is Saved
- After any list operation (create, delete, select)
- After any item operation (add, edit, delete, toggle)
- After completing shopping trip
- On app initialization (load)

## 🧮 Prediction Algorithm

### Input
```dart
Purchase History: [
  { itemName: "milk", boughtAt: "2024-11-01" },
  { itemName: "milk", boughtAt: "2024-11-08" },
  { itemName: "bread", boughtAt: "2024-11-14" },
]
```

### Processing
```dart
1. Group by item name:
   milk: [2024-11-01, 2024-11-08]
   bread: [2024-11-14]

2. Calculate scores:
   milk:
     frequency = 2
     recency = 1 / (today - 2024-11-08).days = 1/8 = 0.125
     score = 2 × 0.125 = 0.25
   
   bread:
     frequency = 1
     recency = 1 / (today - 2024-11-14).days = 1/2 = 0.5
     score = 1 × 0.5 = 0.5

3. Sort by score: [bread (0.5), milk (0.25)]
4. Filter out items in current list
5. Return top 8
```

### Output
```dart
["bread", "milk"]
```

## 📊 Expense Calculation

### Monthly Total
```dart
1. Get all purchases this month (boughtAt >= first day of month)
2. For each purchase:
   - Find matching item in any list
   - Add item.price to total
3. Return total
```

### Category Breakdown
```dart
1. Get all purchases this month
2. Group by item.category
3. Sum prices per category
4. Calculate percentages
5. Return Map<String, double>
```

## 🎨 UI Architecture

### Material 3 Theme
```dart
ThemeData(
  colorSchemeSeed: Colors.green,
  useMaterial3: true,
  brightness: Brightness.light,
)
```

### Component Types
- **Pages**: Full-screen views with AppBar
- **Widgets**: Reusable components
- **Sheets**: Bottom sheets for forms/lists
- **Cards**: Content containers
- **Tiles**: List items

### Responsive Design
- Mobile-first approach
- Touch targets ≥ 48x48
- Proper padding for keyboards
- Scrollable content areas

## 🔄 Lifecycle

### App Startup
```
1. main() called
2. WidgetsFlutterBinding.ensureInitialized()
3. Create GroceryProvider
4. await provider.load()
5. Wrap app with ChangeNotifierProvider
6. Build AutonoticApp
7. Show MainShell
8. Display ListsPage (default tab)
```

### Adding Item Flow
```
1. User taps FAB
2. showModalBottomSheet(AddEditItemSheet)
3. User fills form
4. User taps "Add"
5. Navigator.pop(context, item)
6. provider.addItem(item)
7. State updated
8. notifyListeners()
9. UI rebuilds
10. Sheet closes
```

## 🧪 Testing Strategy (Future)

### Unit Tests
- Model serialization
- Prediction algorithm
- Expense calculations
- Date logic

### Widget Tests
- Individual widgets
- User interactions
- Form validation
- Navigation

### Integration Tests
- Complete user flows
- Data persistence
- State management
- Cross-page navigation

## 🚀 Performance Considerations

### Optimizations
- Const constructors for static widgets
- ListView.builder for large lists
- Selective rebuilds with context.select
- Lazy loading with FutureBuilder

### Potential Bottlenecks
- Large purchase history (>1000 items)
- Complex prediction calculations
- JSON serialization on every save

### Solutions
- Limit purchase history to 6 months
- Cache prediction results
- Debounce save operations

## 🔮 Future Extensions

### Easy Additions
- More categories
- Custom themes
- Export/import data
- Multiple currencies

### Medium Complexity
- Cloud sync (Firebase)
- User authentication
- List sharing
- Recipe integration

### Advanced Features
- Machine learning predictions
- Barcode scanning
- Voice input
- Smart notifications
- Store location mapping

## 📐 Code Organization Principles

1. **Single Responsibility**: Each file has one purpose
2. **DRY**: Reusable widgets and functions
3. **KISS**: Simple, straightforward logic
4. **Separation of Concerns**: UI, logic, data separate
5. **Composition**: Small widgets combined
6. **Immutability**: Models use copyWith patterns

## 🎓 Learning Resources

### Flutter Concepts Used
- StatefulWidget & StatelessWidget
- Provider state management
- Navigation & routing
- Bottom sheets & dialogs
- Forms & validation
- ListView & scrolling
- Material 3 components
- Async/await
- JSON serialization
- Local storage

### Best Practices Followed
- Null safety
- Const constructors
- Named parameters
- Factory constructors
- Extension methods (getters)
- Error handling
- User feedback (snackbars)
- Loading states
- Empty states

---

**Architecture Status**: ✅ Production-Ready

This architecture supports all MVP requirements and is designed for easy extension to mobile platforms and cloud services.

