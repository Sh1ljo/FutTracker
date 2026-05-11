# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Start

**Build & Run:**
- `flutter pub get` – Install dependencies
- `flutter run` – Run app on connected device/emulator (debug mode)
- `flutter run --release` – Build release version
- `flutter test` – Run unit/widget tests
- `flutter clean` – Clean build artifacts

**Platform-specific:**
- iOS: `flutter run -d macos` or open `ios/Runner.xcworkspace` in Xcode
- Android: Requires Android Studio/SDK; emulator or connected device
- Web: `flutter run -d web` (if web platform is enabled)

**Code Generation & Linting:**
- `flutter analyze` – Run linter (dart analyze)
- `flutter pub get` – Fetch/update packages
- `flutter pub upgrade` – Upgrade dependencies

## Project Overview

**FutTracker** is a Flutter mobile app for football players to track training sessions, match performance, career statistics, and personal profile information. The app uses local SQLite storage and a Provider-based state management pattern.

### Core Features
- **Dashboard**: Overview of current stats and training streak
- **Training Log**: Record training sessions with intensity, duration, type, and focus areas
- **Matches**: Log match appearances, goals, assists, and in-game statistics
- **Statistics**: View career stats and weekly training data charts
- **Profile**: Store player profile info (name, position, team, jersey number, age, etc.)

## Architecture

### Directory Structure
```
lib/
  main.dart                    # App entry point, MainShell (bottom nav)
  core/
    theme.dart               # Material 3 theme, colors, text styles
  models/
    training_session.dart    # TrainingSession data model
    match.dart               # Match data model
  providers/
    app_provider.dart        # AppProvider (ChangeNotifier) - state management
  screens/
    dashboard_screen.dart
    training_log_screen.dart
    add_training_screen.dart
    matches_screen.dart
    add_match_screen.dart
    statistics_screen.dart
    profile_screen.dart
  data/
    database_helper.dart     # SQLite database access layer
```

### State Management: Provider Pattern

**AppProvider** (lib/providers/app_provider.dart) is the single source of truth:
- Manages 5 data collections: `_sessions`, `_matches`, `_dashboardStats`, `_careerStats`, `_profile`
- Loads all data on app startup via `loadAll()` (called from main.dart)
- Provides getters for computed values like `trainingStreak` (consecutive days with training)
- Convenience getters for profile fields: `profileName`, `profilePosition`, `profileTeam`, etc.
- Methods: `addSession/updateSession/deleteSession`, `addMatch/updateMatch/deleteMatch`, `saveProfile`
- After any data mutation, calls `loadAll()` to refresh all state and notify listeners

**Key Pattern**: Every mutation method (add/update/delete) triggers a full `loadAll()` refresh. This ensures UI stays in sync but means the provider reloads aggregates on every change.

### Database: SQLite (sqflite)

**DatabaseHelper** (lib/data/database_helper.dart):
- Singleton pattern with lazy initialization
- Three main tables:
  - `training_sessions`: id, date, duration, intensity, distance, location, notes, training_type, calories_burned, heart_rate_avg, focus_areas
  - `matches`: id, date, opponent, home_team, home_score, away_score, goals, assists, passes, tackles, minutes_played, rating, notes
  - `profile`: key-value pairs for player profile data
- Version 3 with migrations (`_onUpgrade`)
- Seeds sample data on first run (4 training sessions, 3 matches)
- Aggregation methods: `getDashboardStats()`, `getCareerStats()` (includes weekly training breakdown)

### Data Models

**TrainingSession** (lib/models/training_session.dart):
- Core fields: date (YYYY-MM-DD), duration (mins), intensity (1-5), distance (km), location, notes
- Enriched fields: trainingType (e.g., "Tactical", "Fitness", "Recovery"), caloriesBurned, heartRateAvg
- focusAreas stored as comma-separated string, parsed via getter `focusAreaList`
- `intensityLabel` getter maps 1-5 to readable labels
- `copyWith()` and `toMap()/fromMap()` for serialization

**Match**:
- Date, opponent, home/away team, scores, player stats (goals, assists, passes, tackles, minutesPlayed, rating)
- Computed `result` getter ("Win"/"Loss"/"Draw")
- Same serialization pattern as TrainingSession

### Theme & Design System

**AppColors** (lib/core/theme.dart):
- Material 3 color scheme with vibrant green as primary (#006C49, container #10B981)
- Secondary green (#1B6B4F, container #A6F2CF)
- Off-white surfaces (#F4FBF4) and dark on-surface (#161D19)

**AppTextStyles**:
- h1, h2, h3 in Lexend (athletic, bold headings)
- bodyLg, bodyMd in Inter (readable body copy)
- labelMd, labelSm for secondary text
- All styles are context-aware (for responsive sizing if needed)

**buildAppTheme()**:
- Applies Material 3 theme with custom color scheme
- Card theme: white fill, light border, 10px radius
- Input decoration: filled white with green focus state
- Button styles: elevated (green bg) and outlined variants
- Navigation bar uses secondary container for indicators

## Common Development Tasks

### Adding a New Feature

1. **Add data to model** if needed (TrainingSession, Match, or Profile)
2. **Update database schema** in DatabaseHelper:
   - Modify `_createDB()` for new tables/columns
   - Increment version in `_initDB()`
   - Add migration logic in `_onUpgrade()`
3. **Add database methods** in DatabaseHelper (insert, query, update, delete)
4. **Wire into AppProvider**:
   - Add private field(s) and getter(s)
   - Add load method (e.g., `_loadNewData()`)
   - Add it to `loadAll()` Future.wait() list
   - Add any mutation methods
5. **Create/update screen** and call provider methods via `context.read<AppProvider>()` or `context.watch<AppProvider>()`

### Adding a Training Session Field

- Update `TrainingSession` model (add field, update `toMap()`, `fromMap()`, `copyWith()`)
- Alter database table: `_onUpgrade()` → `ALTER TABLE training_sessions ADD COLUMN ...`
- Update `add_training_screen.dart` form and submission
- Update stats calculations in `getDashboardStats()` or `getCareerStats()` if needed

### Testing the App

- Widget tests go in `test/` directory
- Run all: `flutter test`
- Run single file: `flutter test test/widget_test.dart`
- Provider state is testable via `ChangeNotifier` and `test` package (not shown in current setup but can be added)

## Key Decisions & Patterns

- **Full reload on mutation**: Every `add/update/delete` calls `loadAll()`. This is simple but could be optimized with targeted updates if performance becomes an issue.
- **Local-only data**: No backend sync; all data persists in SQLite on device
- **No null-coalescing complexity**: Models use nullable fields where optional; getters have sensible defaults (e.g., profile fields default to hardcoded values)
- **Comma-separated string storage**: focusAreas in TrainingSession and skill strings in Profile are stored as comma-delimited text, parsed on the fly
- **Seed data**: Populated fresh on app install for demo purposes (clear database to reset)

## Design System Reminders

- **Spacing**: 4px (xs), 8px (sm), 16px (md), 24px (lg), 32px (xl)
- **Radius**: 10px for cards, buttons, inputs
- **Elevation**: Flat design; use tonal layers and borders instead of shadows
- **Icons**: MaterialIcons or cupertino_icons package
- **Responsive**: Mobile-first, screens adapt to available width (e.g., DashboardScreen, MatchesScreen)

## Dependencies

- `flutter` & `dart` (SDK 3.6.0+)
- `provider` ^6.1.2 – State management
- `sqflite` ^2.3.3 – SQLite database
- `google_fonts` ^6.2.1 – Lexend and Inter fonts
- `fl_chart` ^0.69.0 – Charts (used in statistics screen)
- `intl` ^0.19.0 – Internationalization & date formatting
- `cupertino_icons` & Material icons – Icon packages

## Resources

- [Flutter docs](https://docs.flutter.dev)
- [Provider pattern guide](https://pub.dev/packages/provider)
- [sqflite reference](https://pub.dev/packages/sqflite)
- [Material 3 design](https://m3.material.io)
- See `Design/pitch_performance_system/DESIGN.md` for detailed design system spec
