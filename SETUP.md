# Quick Setup Guide for Autonotic

## 🚀 Quick Start (3 steps)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Enable Web Support
```bash
flutter config --enable-web
```

### 3. Run the App
```bash
flutter run -d chrome
```

That's it! The app should open in Chrome.

## 📱 What You'll See

### First Launch
- A default "Weekly" grocery list is created automatically
- Empty list with a helpful message
- Two tabs: Lists and Dashboard

### Try These Features

1. **Add an Item**
   - Click the + button
   - Enter "Milk" as the name
   - Set price to "3.99"
   - Select "Dairy" category
   - Optionally set an expiry date
   - Click Add

2. **Check Off Items**
   - Tap the checkbox next to an item
   - Notice the strike-through effect

3. **Complete a Shopping Trip**
   - Check off some items
   - Click "Complete Trip" button
   - Items are removed and added to history

4. **View Suggestions**
   - After completing a trip, click "Suggestions"
   - See predicted items based on your history
   - Add suggestions with one tap

5. **Track Expenses**
   - Switch to the Dashboard tab
   - See total spent this month
   - View breakdown by category

## 🎨 Customization

### Change Theme Color
Edit `lib/app.dart`:
```dart
colorSchemeSeed: Colors.green,  // Change to Colors.blue, Colors.purple, etc.
```

### Add More Categories
Edit `lib/widgets/add_edit_item_sheet.dart`:
```dart
final List<String> _categories = [
  'Fruits & Vegetables',
  'Dairy',
  // Add your categories here
];
```

### Adjust Expiry Warning Period
Edit `lib/models/grocery_item.dart`:
```dart
bool get isExpiringSoon {
  if (expiry == null) return false;
  final now = DateTime.now();
  final difference = expiry!.difference(now);
  return difference.inDays >= 0 && difference.inDays <= 3;  // Change 3 to your preferred days
}
```

## 🐛 Troubleshooting

### "Chrome not found"
Make sure Chrome is installed and run:
```bash
flutter devices
```
You should see "Chrome" in the list.

### "Package not found"
Run:
```bash
flutter clean
flutter pub get
```

### "Web not enabled"
Run:
```bash
flutter config --enable-web
flutter doctor
```

### Hot Reload Not Working
Press `r` in the terminal or save a file to trigger hot reload.

## 📦 Building for Production

### Build Web App
```bash
flutter build web
```

Output will be in `build/web/` directory.

### Deploy to Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

### Deploy to GitHub Pages
1. Build the app: `flutter build web`
2. Copy `build/web/*` to your GitHub Pages repo
3. Commit and push

### Deploy to Netlify
1. Build the app: `flutter build web`
2. Drag and drop the `build/web` folder to Netlify
3. Done!

## 🔧 Development Tips

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode
The app runs in debug mode by default. For better performance:
```bash
flutter run -d chrome --release
```

### View Logs
Open Chrome DevTools (F12) to see console logs and debug.

### Clear Data
To reset the app, open Chrome DevTools > Application > Storage > Clear site data

## 📚 Next Steps

1. **Add Sample Data**: Create a few items and complete a shopping trip
2. **Test Predictions**: Complete 2-3 trips to see suggestions
3. **Track Expenses**: Add prices to items and view the dashboard
4. **Customize**: Change colors, categories, or add new features

## 🎯 Key Files to Know

- `lib/main.dart` - App entry point
- `lib/providers/grocery_provider.dart` - All business logic
- `lib/pages/lists_page.dart` - Main grocery list UI
- `lib/pages/dashboard_page.dart` - Expense tracking UI
- `lib/models/` - Data structures

## 💡 Pro Tips

1. **Use Keyboard Shortcuts**: Press `r` for hot reload during development
2. **Test on Mobile**: Use Chrome DevTools device mode (F12 > Toggle device toolbar)
3. **Check Performance**: Use Flutter DevTools for performance profiling
4. **Version Control**: Commit frequently as you make changes

---

Happy coding! 🎉

