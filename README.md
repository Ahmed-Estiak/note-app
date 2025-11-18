# Autonotic - Smart Grocery List Manager

A Flutter Web MVP for managing grocery lists with intelligent predictions and expense tracking.

## Features

### 📝 Category-Based Organization
- Create multiple categories (Weekly, Monthly, etc.)
- Each category contains bullet-pointed items directly
- Simple and straightforward structure

### 🛒 Smart Item Management
- Type and press Enter to add items quickly
- Inline editing - click on text to edit directly
- Edit button for detailed info (price, category, expiry)
- Delete button appears next to each item
- Check/uncheck items with strike-through styling
- Edit/delete buttons hide during inline editing

### 🔮 Smart Predictions
- Purchase history tracking
- AI-powered suggestions based on frequency × recency
- "Suggestions" button shows 3-8 predicted items
- One-tap to add suggested items to your list

### ⏰ Expiry Awareness
- Optional expiry dates for items
- "Expiring Soon" banner for items expiring within 3 days
- Visual warnings with color-coded alerts
- In-app display only (no push notifications)

### 💰 Monthly Expense Dashboard
- Track spending with optional item prices
- Category-based expense breakdown
- Visual progress bars showing spending distribution
- Monthly total and per-category totals

## Tech Stack

- **Flutter 3.0+** - Cross-platform framework
- **Provider** - State management
- **SharedPreferences** - Local data persistence
- **UUID** - Unique ID generation
- **Intl** - Date formatting
- **Material 3** - Modern UI design with green color scheme

## Project Structure

```
lib/
├── app.dart                          # App configuration
├── main.dart                         # Entry point
├── models/                           # Data models
│   ├── grocery_item.dart            # Item model with expiry logic
│   ├── grocery_list.dart            # List model
│   └── purchase.dart                # Purchase history model
├── providers/                        # State management
│   └── grocery_provider.dart        # Main provider with business logic
├── pages/                            # Main screens
│   ├── main_shell.dart              # Bottom navigation shell
│   ├── lists_page.dart              # Grocery list management
│   └── dashboard_page.dart          # Expense tracking
└── widgets/                          # Reusable components
    ├── add_edit_item_sheet.dart     # Add/edit item bottom sheet
    ├── suggestions_sheet.dart       # AI suggestions bottom sheet
    ├── expiring_banner.dart         # Expiry warning banner
    └── list_selector.dart           # List dropdown selector
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Chrome browser (for web development)
- Git

### Installation

1. **Clone or navigate to the project directory:**
   ```bash
   cd note-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter web is enabled:**
   ```bash
   flutter config --enable-web
   ```

4. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

### Building for Production

To build a production-ready web app:

```bash
flutter build web
```

The output will be in the `build/web/` directory, ready to deploy to any static hosting service.

## Usage Guide

### Managing Lists

1. **Select a list** using the dropdown at the top
2. **Create a new list** by clicking the + icon next to the dropdown
3. **Delete a list** by clicking the trash icon (requires at least 2 lists)

### Adding Items

1. Click the **+** floating action button
2. Fill in item details:
   - **Name** (required)
   - **Price** (optional, for expense tracking)
   - **Category** (default: Other)
   - **Expiry Date** (optional, for expiry warnings)
3. Click **Add** to save

### Editing Items

1. Click the **edit** icon on any item
2. Modify the details
3. Click **Update** to save changes

### Completing a Shopping Trip

1. Check off items as you purchase them
2. Click **Complete Trip** button
3. Checked items will be:
   - Removed from the list
   - Added to purchase history for predictions
   - Used for expense tracking (if prices are set)

### Getting Suggestions

1. Click the **Suggestions** button
2. View AI-predicted items based on your history
3. Click the **+** icon to add suggestions to your list
4. Suggestions are based on:
   - **Frequency**: How often you buy the item
   - **Recency**: How recently you bought it

### Viewing Expenses

1. Navigate to the **Dashboard** tab
2. View:
   - Total spent this month
   - Spending breakdown by category
   - Percentage distribution with visual bars

## Data Persistence

All data is stored locally in your browser using SharedPreferences:
- Grocery lists and items
- Purchase history
- Selected list preference

**Note:** Clearing browser data will reset the app.

## Mobile-Friendly Design

The app is optimized for mobile devices:
- Responsive layout
- Touch-friendly buttons and controls
- Bottom sheets for forms
- Material 3 design with green theme

## Future Enhancements

This MVP can be extended with:
- Android/iOS native apps
- Cloud sync across devices
- Barcode scanning
- Recipe integration
- Shopping list sharing
- Push notifications for expiring items
- Advanced analytics and insights

## Development Notes

### Key Design Decisions

1. **Simple prediction algorithm**: Frequency × Recency keeps it lightweight
2. **No external APIs**: Everything runs locally for MVP speed
3. **Material 3**: Modern, accessible design out of the box
4. **Provider pattern**: Simple state management, easy to understand
5. **JSON storage**: Easy to debug and migrate later

### Extending the App

To add new features:
1. **New data fields**: Update models in `lib/models/`
2. **New business logic**: Extend `GroceryProvider`
3. **New screens**: Add to `lib/pages/`
4. **New components**: Add to `lib/widgets/`

## Troubleshooting

### App doesn't load
- Ensure Flutter web is enabled: `flutter config --enable-web`
- Clear browser cache and reload
- Check console for errors

### Data not persisting
- Check browser storage settings
- Ensure SharedPreferences is working: `flutter doctor`

### Build errors
- Run `flutter clean` then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`

## License

This project is created as an MVP for Autonotic.

## Support

For issues or questions, please check:
- Flutter documentation: https://flutter.dev/docs
- Provider package: https://pub.dev/packages/provider

---

**Built with Flutter 💙 | Material 3 Design 🎨 | Smart Predictions 🧠**
