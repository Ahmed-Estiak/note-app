# Testing Guide for Autonotic

## 🧪 Manual Testing Checklist

### Initial Setup
- [ ] Run `flutter pub get`
- [ ] Run `flutter run -d chrome`
- [ ] App loads without errors
- [ ] Default "Weekly" list is created

### List Management
- [ ] Can see "Weekly" list in selector
- [ ] Can create new list (e.g., "Monthly")
- [ ] Can switch between lists
- [ ] Can delete a list (when >1 exists)
- [ ] Cannot delete last remaining list
- [ ] Selected list persists after reload

### Adding Items
- [ ] Click FAB opens bottom sheet
- [ ] Can add item with name only
- [ ] Can add item with all fields
- [ ] Name field is required
- [ ] Price accepts decimals (e.g., 3.99)
- [ ] Category dropdown works
- [ ] Date picker opens and works
- [ ] Can clear expiry date
- [ ] Item appears in list after adding

### Editing Items
- [ ] Click edit icon opens sheet
- [ ] Form pre-fills with existing data
- [ ] Can modify all fields
- [ ] Changes save correctly
- [ ] Updated item shows in list

### Deleting Items
- [ ] Click delete shows confirmation
- [ ] Can cancel deletion
- [ ] Item removed after confirmation
- [ ] List updates correctly

### Checking Items
- [ ] Can check/uncheck items
- [ ] Checked items show strike-through
- [ ] Checked items change color
- [ ] State persists after reload

### Expiry Warnings
- [ ] Add item expiring today → shows in banner
- [ ] Add item expiring tomorrow → shows in banner
- [ ] Add item expiring in 3 days → shows in banner
- [ ] Add item expiring in 4 days → not in banner
- [ ] Banner shows correct "Today/Tomorrow/in X days"
- [ ] Banner hides when no expiring items
- [ ] Expiring items show orange color

### Completing Shopping Trip
- [ ] Button disabled when no checked items
- [ ] Button enabled when items checked
- [ ] Shows confirmation dialog
- [ ] Can cancel completion
- [ ] Checked items removed after completion
- [ ] Unchecked items remain
- [ ] Success snackbar appears
- [ ] Purchase history updated

### Suggestions
- [ ] Button opens bottom sheet
- [ ] Shows "No suggestions" for new users
- [ ] After completing trip, suggestions appear
- [ ] Can add suggestion to list
- [ ] Success snackbar appears
- [ ] Suggestions don't include existing items
- [ ] Shows 3-8 items max

### Dashboard
- [ ] Switch to Dashboard tab
- [ ] Shows $0.00 initially
- [ ] Shows empty state message
- [ ] After completing trip with prices, shows total
- [ ] Category breakdown appears
- [ ] Progress bars show correctly
- [ ] Percentages add up to 100%
- [ ] Only shows current month data

### Data Persistence
- [ ] Add items, reload page → items persist
- [ ] Check items, reload → state persists
- [ ] Complete trip, reload → history persists
- [ ] Switch list, reload → selection persists
- [ ] Dashboard data persists

### Responsive Design
- [ ] Works on desktop (1920x1080)
- [ ] Works on tablet (768x1024)
- [ ] Works on mobile (375x667)
- [ ] Bottom sheets adjust for keyboard
- [ ] Scrolling works on all screens
- [ ] Touch targets are adequate

### Error Handling
- [ ] Cannot submit empty item name
- [ ] Invalid price rejected
- [ ] Cannot delete last list
- [ ] Graceful handling of missing data

## 📝 Test Scenarios

### Scenario 1: First-Time User
```
1. Open app
2. See "Weekly" list with empty state
3. Add "Milk" ($3.99, Dairy, expires in 2 days)
4. Add "Bread" ($2.49, Bakery, no expiry)
5. Add "Apples" ($4.99, Fruits & Vegetables, expires in 5 days)
6. Check "Milk" and "Bread"
7. Click "Complete Trip"
8. Confirm completion
9. See only "Apples" remaining
10. See expiring banner for "Milk" (should not appear)
11. Click "Suggestions" → see "No suggestions"
```

**Expected**: All operations work smoothly, data persists

### Scenario 2: Regular User
```
1. Open app (with existing data)
2. Click "Suggestions"
3. See "Milk" and "Bread" suggested
4. Add "Milk" from suggestions
5. Manually add "Eggs" ($4.99, Dairy, expires tomorrow)
6. See expiring banner with "Eggs"
7. Check all items
8. Complete trip
9. Go to Dashboard
10. See total: $9.98
11. See Dairy: $8.98 (80.2%)
12. See Bakery: $0.00 (not shown if no purchases)
```

**Expected**: Predictions work, expenses calculated correctly

### Scenario 3: Multiple Lists
```
1. Create "Monthly" list
2. Add items to "Monthly"
3. Switch to "Weekly"
4. See different items
5. Complete trip on "Weekly"
6. Switch to "Monthly"
7. See items still there
8. Delete "Monthly"
9. Auto-switch to "Weekly"
10. Cannot delete "Weekly" (last list)
```

**Expected**: Lists are independent, deletion works correctly

### Scenario 4: Expiry Management
```
1. Add "Yogurt" expiring today
2. Add "Cheese" expiring tomorrow
3. Add "Butter" expiring in 3 days
4. Add "Milk" expiring in 4 days
5. See banner with Yogurt, Cheese, Butter
6. Milk not in banner
7. Check "Yogurt"
8. Yogurt still in banner (not done)
9. Complete trip
10. Banner updates (Yogurt removed)
```

**Expected**: Expiry logic works correctly, banner updates

### Scenario 5: Expense Tracking
```
1. Add 5 items with prices in different categories
2. Check all items
3. Complete trip
4. Go to Dashboard
5. Verify total is sum of all prices
6. Verify category totals are correct
7. Verify percentages add up to ~100%
8. Add more items next day
9. Complete trip
10. Dashboard updates with new total
```

**Expected**: Math is correct, updates work

## 🐛 Known Limitations (MVP)

1. **No undo**: Deleted items cannot be recovered
2. **No search**: Large lists require scrolling
3. **No sorting**: Items appear in add order
4. **No bulk operations**: Must check items one by one
5. **No export**: Cannot export data
6. **Browser-only**: Data not synced across devices
7. **No images**: Cannot add item photos
8. **No barcode**: Must type item names
9. **Simple predictions**: No ML, just frequency × recency
10. **Month-only expenses**: No custom date ranges

## 🎯 Performance Testing

### Large Data Sets
```
1. Add 50 items to a list
2. Check scrolling performance
3. Complete trip with 50 items
4. Check prediction calculation time
5. Add 100 purchases to history
6. Check suggestions response time
7. Switch between lists
8. Check load time
```

**Expected**: No lag, smooth animations

### Edge Cases
```
1. Add item with very long name (100 chars)
2. Add item with price $9999.99
3. Set expiry date 1 year in future
4. Create 20 different lists
5. Add same item name multiple times
6. Complete trip with 0 items checked
7. Delete all items from a list
8. Switch lists rapidly
```

**Expected**: Graceful handling, no crashes

## 🔍 Browser Testing

### Chrome (Primary)
- [ ] Desktop
- [ ] Mobile emulation
- [ ] Tablet emulation

### Firefox
- [ ] Desktop
- [ ] Mobile emulation

### Safari (if available)
- [ ] Desktop
- [ ] Mobile

### Edge
- [ ] Desktop

## 📊 Test Data Sets

### Minimal Data
```json
{
  "lists": [
    {
      "id": "list-1",
      "name": "Weekly",
      "items": [
        {
          "id": "item-1",
          "name": "Milk",
          "price": 3.99,
          "category": "Dairy",
          "done": false
        }
      ]
    }
  ],
  "purchase_history": [],
  "selected_list_id": "list-1"
}
```

### Rich Data
```json
{
  "lists": [
    {
      "id": "list-1",
      "name": "Weekly",
      "items": [
        {
          "id": "item-1",
          "name": "Milk",
          "price": 3.99,
          "category": "Dairy",
          "expiry": "2024-11-18T00:00:00.000Z",
          "done": false
        },
        {
          "id": "item-2",
          "name": "Bread",
          "price": 2.49,
          "category": "Bakery",
          "done": true
        },
        {
          "id": "item-3",
          "name": "Apples",
          "price": 4.99,
          "category": "Fruits & Vegetables",
          "expiry": "2024-11-20T00:00:00.000Z",
          "done": false
        }
      ]
    },
    {
      "id": "list-2",
      "name": "Monthly",
      "items": []
    }
  ],
  "purchase_history": [
    {
      "itemName": "milk",
      "boughtAt": "2024-11-01T10:00:00.000Z"
    },
    {
      "itemName": "milk",
      "boughtAt": "2024-11-08T10:00:00.000Z"
    },
    {
      "itemName": "bread",
      "boughtAt": "2024-11-14T10:00:00.000Z"
    }
  ],
  "selected_list_id": "list-1"
}
```

## 🚨 Critical Bugs to Watch For

1. **Data loss**: Items disappearing after reload
2. **Duplicate items**: Same item appearing multiple times
3. **Incorrect calculations**: Wrong totals or percentages
4. **UI freezing**: App becoming unresponsive
5. **Navigation issues**: Cannot switch tabs or lists
6. **Form validation**: Can submit invalid data
7. **State inconsistency**: UI not matching data
8. **Memory leaks**: Performance degrading over time

## ✅ Definition of Done

A feature is complete when:
- [ ] Functionality works as specified
- [ ] No console errors
- [ ] No linter warnings
- [ ] Data persists correctly
- [ ] UI is responsive
- [ ] User feedback provided (snackbars)
- [ ] Edge cases handled
- [ ] Works on mobile size
- [ ] Accessible (keyboard, screen readers)
- [ ] Documented in code

## 🎓 Testing Tips

1. **Use Chrome DevTools**: F12 for console, network, storage
2. **Test mobile first**: Most users will be on mobile
3. **Clear data often**: Application > Storage > Clear site data
4. **Check console**: Look for warnings and errors
5. **Test edge cases**: Empty states, max values, etc.
6. **Reload frequently**: Ensure persistence works
7. **Test slowly**: Give animations time to complete
8. **Use real data**: Test with realistic item names and prices

## 📈 Success Metrics

- [ ] All features work without errors
- [ ] Data persists across sessions
- [ ] Predictions improve with use
- [ ] Expenses calculate correctly
- [ ] UI is intuitive and responsive
- [ ] No performance issues
- [ ] Ready for user testing

---

**Testing Status**: Ready for manual testing

Run through all scenarios to ensure MVP quality before deployment.

