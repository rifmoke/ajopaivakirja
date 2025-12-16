# Ajopäiväkirja - AI Coding Agent Instructions

## Project Overview
Flutter-based driving diary (mileage tracker) and expense management mobile app for Android and iOS. Uses Finnish language in UI. Supports both work and private trip tracking, expense management with receipt photos, and subscription-based premium features.

## Architecture

### Core Structure
- **Provider pattern** for state management (trip_provider, expense_provider, subscription_provider)
- **SQLite** for local data persistence (database_helper.dart)
- **4-tab bottom navigation**: Home, Add Trip, Expenses, Settings
- **Separate Navigator** for Expenses section (3-screen stack)

### Key Data Models
- **Trip**: date, tripType (work/private), odometer readings, GPS coordinates, addresses
- **Expense**: date, category (11 types), amount, fuel-specific fields (liters, price/L), receipt path
- **Subscription**: 30-day free trial, monthly/yearly plans

### Database Schema
```sql
trips: id, date, tripType, startOdometer, endOdometer, addresses, GPS coords, notes
expenses: id, date, category, amount, company, liters, pricePerLiter, receiptPath, notes
```

## Color Scheme (AppTheme)
- Primary: `#FF1919` (bright red) - buttons, work trips, highlights
- Secondary: `#191919` (dark gray) - navigation, headers
- Private trips: `#666666` (medium gray)
- Background: `#F5F5F5` (light gray)
- Cards: `#FFFFFF` with elevation 4

## Critical Patterns

### GPS Location Handling
- Uses `geolocator` for coordinates, `geocoding` for address resolution
- Permission requests handled in add_trip_page.dart
- Coordinates stored alongside addresses for future features

### Receipt Management
- Images stored in `app_documents/receipts/` with timestamp-based filenames
- Paths stored as strings in database
- Copy files to app directory (don't reference external storage directly)

### CSV Import/Export
- Headers must match exact structure (see esimerkkitaulukko.csv, esimerkkikulut.csv)
- Use `csv` package with `ListToCsvConverter` / `CsvToListConverter`
- Handle empty fields with null checks in fromCsvRow() methods

### Backup System
- **Trips**: CSV files only
- **Expenses**: ZIP archives containing CSV + receipt images (use `archive` package)
- Share files via `share_plus` after creation

### Subscription Flow
1. SubscriptionProvider checks SharedPreferences for trial/subscription status
2. Auto-grants 30-day trial on first launch
3. In-app purchases via `in_app_purchase` package
4. Product IDs: `ajopaivakirja_monthly`, `ajopaivakirja_yearly`
5. Must configure products in App Store Connect and Google Play Console before release

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run on device
flutter run
```

## Platform-Specific Configuration

### Android (AndroidManifest.xml)
- Permissions: FINE_LOCATION, COARSE_LOCATION, CAMERA, READ/WRITE_EXTERNAL_STORAGE
- App name: "Ajopäiväkirja" (not "ajopaivakirja")
- Min SDK: 21, Target SDK: 36

### iOS (Info.plist)
- Location usage descriptions (both "when in use" and "always")
- Camera and Photo Library usage descriptions
- All descriptions in Finnish

## Common Tasks

### Adding a new expense category
1. Add to `ExpenseCategory.all` list in models/expense.dart
2. No UI changes needed (horizontal scroll handles any count)

### Modifying statistics calculations
- Trip stats: providers/trip_provider.dart (getWeeklyKilometers, etc.)
- Expense stats: providers/expense_provider.dart (getCategoryExpenses, getMonthlyExpenses)
- Use fold() for aggregations, where() for filtering

### Charts (fl_chart)
- **LineChart**: Weekly trips (home_page.dart)
- **PieChart**: Expense categories (expenses_page.dart)
- **BarChart**: Monthly expenses (expenses_page.dart), yearly trips (history_page.dart)
- All use AppTheme.primaryRed as main color

## Testing Considerations
- Mock GPS locations for trip testing
- Use esimerkkitaulukko.csv / esimerkkikulut.csv for CSV import tests
- Test subscription flow in sandbox environment (requires real device)
- Verify receipt images persist after app restart

## Known Dependencies Versions
```yaml
flutter: 3.38.5
provider: ^6.1.2
sqflite: ^2.3.3+1
geolocator: ^13.0.2
fl_chart: ^0.69.0
in_app_purchase: ^3.2.2
```

## Important Notes
- **Never hardcode GPS coordinates** - always request location permission first
- **Always copy receipt images** to app directory before storing paths
- **Check mounted** before using BuildContext after async operations
- **Handle SQLite null values** properly in fromMap() methods
- **Test CSV format** - Excel adds extra columns if not careful
- **Subscription product IDs** must match store configuration exactly

## File Organization
```
lib/
├── config/theme.dart          # AppTheme with color constants
├── models/                    # Data models with CSV serialization
├── providers/                 # State management (ChangeNotifier)
├── screens/                   # UI pages (home, add_trip, expenses, etc.)
└── services/database_helper.dart  # SQLite operations
```

## Deployment Checklist
- [ ] Configure app signing (Android keystore, iOS certificates)
- [ ] Set up in-app purchase products in both stores
- [ ] Update app version in pubspec.yaml
- [ ] Generate app icons from ajopäiväkirja.png
- [ ] Test CSV import/export with real data
- [ ] Verify GPS permissions on both platforms
- [ ] Test subscription restore purchases
