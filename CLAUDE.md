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

## Communication & Work Standards

- **Addressing**: You will be addressed as "sir" and will address me as "sir"
- **Error checking**: After completing any task, you must check for errors before reporting completion
- **Subagents**: You may spawn subagents if you deem it necessary for the task

## Project Overview

**FutTracker** is a Flutter mobile app for football players to track training sessions, match performance, career statistics, and personal profile information. The app uses local SQLite storage and a Provider-based state management pattern.

### Core Features

- **Dashboard**: Overview of current stats and training streak
- **Training Log**: Record training sessions with intensity, duration, type, and focus areas
- **Matches**: Log match appearances, goals, assists, and in-game statistics
- **Form Guide**: View recent form statistics from matches in the last 30 days (home/away splits, win rates, average ratings)
- **Statistics**: View career stats and weekly training data charts
- **Profile**: Store player profile info (name, position, team, jersey number, age, etc.)

## Recent Implementation Update (May 2026) — VERIFIED ✅

**All 5 features verified and working correctly** — `flutter analyze` reports no issues.

### 1. **Actionable Insights Card (Statistics screen)** ✅
   - Converts tracked data into 1–3 plain coaching tips
   - Tips evaluate: weekly session consistency, recent intensity levels, monthly rating vs. goal, focus skill progress
   - Location: [lib/screens/statistics_screen.dart](lib/screens/statistics_screen.dart) — `_buildActionableInsightsCard()`, `_buildInsights()`

### 2. **Lightweight Goal System (3 goals)** ✅
   - Profile-backed SQLite fields: `weekly_goal` (session target, default 5), `goal_avg_rating` (monthly target, default 7.0), `goal_focus_skill` + `goal_focus_sessions` (weekly skill target)
   - Provider getters: `profileWeeklyGoal`, `profileAvgRatingGoal`, `profileFocusSkill`, `profileFocusSkillSessionsGoal`
   - Goal controls in Edit Profile under Performance Goals

### 3. **4-Week Trend Indicators (Statistics screen)** ✅
   - Trend tiles: Weekly training minutes, Average match rating, Goals + assists per match
   - Trend output: "Improving/Declining · ↑/↓ value" (e.g., "Improving · up 2.5 mins")
   - Logic: `_weeklyTrainingMinutes()`, `_weeklyAverageRating()`, `_weeklyGoalContribution()`, `_trendLabel()`
   - Period selector: Week/Month/All Time

### 4. **Training-to-Match Impact (Form Guide)** ✅
   - Composite form score (0.0–10.0):
     - **Match**: rating (×0.30 = max 3.0), goals (max 2.0), assists (max 1.4), passes (max 1.2), tackles (max 0.9), minutes (max 0.8), result bonus (W=0.7, D=0.35)
     - **Training**: intensity (max 4.0), duration (max 3.0), distance (max 1.5), calories (max 1.5)
   - Chart: Latest 8 entries (M=match, T=training, chronological)
   - Weekly progress bar: sessions vs. goal
   - Location: [lib/screens/form_guide_screen.dart](lib/screens/form_guide_screen.dart)

### 5. **Data Quality & Input UX Upgrades** ✅

   **Training form** ([lib/screens/add_training_screen.dart](lib/screens/add_training_screen.dart)):
   - Validation ranges: Duration 5–240 mins (required), Distance 0–30 km, Calories 0–2500 kcal, Heart rate 60–220 bpm
   - Quick presets: [30, 45, 60, 75, 90] min chips
   - Error messages: "Use 5-240 mins", "Use 60-220 bpm", etc.

   **Match form** ([lib/screens/add_match_screen.dart](lib/screens/add_match_screen.dart)):
   - Validation ranges: Minutes 0–130, Rating 1–10, Scores/Goals/Assists/Tackles 0–25, Passes 0–200
   - Quick presets: [60/75/90 min] + [Rating 6/7/8] buttons
   - Error feedback: "0-130", "1-10", etc.

### Implementation Status: Complete ✅
- Code Quality: `flutter analyze` → No issues found
- Database: Profile goal columns created & migrated
- Provider: Goal getters tested & wired to calculations
- Screens: All 4 screens verified functional (Stats, Form Guide, Add Training, Add Match)

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
    form_guide_screen.dart       # Form guide - 30-day match stats (home/away, win rates, ratings)
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

**Form Guide Performance Calculation**

- **File**: [lib/screens/form_guide_screen.dart](lib/screens/form_guide_screen.dart)
- **Data sources**: `matches` and `sessions` from `AppProvider`, filtered to the last 30 days.
- **Entry construction**: Each `Match` becomes a `_FormEntry` with `score: _calculateMatchScore(match)` and `isMatch: true`; each `TrainingSession` becomes a `_FormEntry` with `score: _calculateTrainingScore(session)` and `isMatch: false`. Entries are sorted by date and the chart shows the latest 8 entries (take 8 then reversed for chronological display). Bottom labels append `M` for match or `T` for training.
- **Match score components**: `rating` (`rating.clamp(0,10) * 0.30`, up to 3.0), `goals` (`min(2.0, goals * 1.0)`, up to 2.0), `assists` (`min(1.4, assists * 0.7)`, up to 1.4), `passes` (`min(1.2, (passes/60)*1.2)`), `tackles` (`min(0.9, (tackles/10)*0.9)`), `minutes` (`min(0.8, (minutesPlayed/90)*0.8)`), and a result bonus (Win=0.7, Draw=0.35). The components sum and are clamped to `0.0–10.0`.
- **Training score components**: `intensity` (`(intensity.clamp(1,5)/5) * 4.0`, up to 4.0), `duration` (`min(3.0, (duration/60)*3.0)`, up to 3.0), `distance` (`min(1.5, (distance/8.0)*1.5)`, up to 1.5), and `calories` (`min(1.5, (caloriesBurned/800)*1.5)`, up to 1.5). Sum is clamped to `0.0–10.0`.
- **Chart scaling & display**: Plotted as `FlSpot(index, score)`; `minY = 0`, `maxY = max(10.0, ceil(peakScore) + 1.0)` so the chart auto-expands above the highest point but never below 10. Line is curved with dots and an under-area tint.
- **Average form**: `_calculateAverageForm()` computes the mean of all entry scores (used in the "Overall Form" card).
- **Models & fields used**: See [lib/models/match.dart](lib/models/match.dart) (`rating`, `goals`, `assists`, `passes`, `tackles`, `minutesPlayed`, scores for `result`) and [lib/models/training_session.dart](lib/models/training_session.dart) (`intensity`, `duration`, `distance`, `caloriesBurned`).
- **Notes**: The scoring is heuristic — weights and caps live in `form_guide_screen.dart`. Adjust those constants to change how match vs training contributes to composite form.

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
