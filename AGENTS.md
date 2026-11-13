# AGENTS.md

Agentic coding instructions for **mezmure_dawit** — a Flutter app displaying Ge'ez/Amharic/English psalms.

---

## 1. Build / Lint / Test Commands

### Core Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter build apk        # Build debug APK
flutter build web        # Build web version
```

### Lint & Analyze
```bash
flutter analyze          # Run full static analysis (required before committing)
```

### Testing
```bash
flutter test                              # Run all tests
flutter test test/widget_test.dart       # Run a single test file
flutter test --name="smoke"              # Run tests matching a pattern
```
- **Test framework:** `flutter_test` (included in dev_dependencies)
- **Minimum Dart SDK:** `>=3.0.0 <4.0.0`

---

## 2. Code Style Guidelines

### Analyzer / Lints
- Uses `package:flutter_lints/flutter.yaml` (the standard Flutter lint set)
- No custom rules enabled; default recommendations apply
- Run `flutter analyze` and fix all warnings/errors before submitting changes

### Dart Conventions

#### Imports
- Flutter/Dart SDK imports first, then package imports, then relative imports
- Use `import 'package:flutter/material.dart';` for all Material widgets
- Use `import 'package:flutter/services.dart';` for `rootBundle`
- Use relative imports for local files: `import 'psalm_data.dart';`

#### Formatting
- Use `dart format` (or `flutter format`) on every changed file before committing
- 2-space indentation, no tabs
- Max line length not enforced, but keep lines readable

#### Types
- Prefer `final` over `var` for immutable variables
- Use explicit types on class fields; local variables may use `var` when type is obvious
- Avoid `dynamic` unless unavoidable; prefer `Object?` or specific interfaces
- Use `late` only when initialization order requires it

#### Naming Conventions
- **Classes/Types:** `PascalCase` (e.g., `PsalmRepository`, `ReadingSanctuary`)
- **Variables/Methods:** `camelCase` (e.g., `allPsalms`, `loadPsalms()`)
- **Private members:** Leading `_` (e.g., `_idx`, `_generateMissingData()`)
- **Constants:** `camelCase` or `kebab-case` in ValueNotifier names (current project uses `camelCase`)
- **Files:** `snake_case.dart`

#### Error Handling
- Use `try/catch` with specific handling; avoid bare `catch (_)` except where errors are intentionally ignored (e.g., `loadPsalms()` silently falls back to empty data)
- Wrap async I/O in try/catch when failure is recoverable
- Use ` ScaffoldMessenger.of(context).showSnackBar(...)` for user-facing error messages

#### Widgets
- Use `const` constructor wherever possible
- Prefer `StatelessWidget` when state is not needed
- Use `ValueNotifier` + `ValueListenableBuilder` for simple cross-widget state (see `AppSettings`, `isDarkMode`, `fontSize`)
- Name state classes with trailing `State` suffix (e.g., `_SacredMainScaffoldState`)
- Use `super.key` in widget constructors

#### Flutter / Material 3
- Always set `useMaterial3: true` in `ThemeData`
- Use `NavigationBar` (not `BottomNavigationBar`) for bottom navigation
- Prefer `AppBar` for top bars
- Suppress `debugShowCheckedModeBanner: false` in `MaterialApp`

#### Asset Handling
- Assets are declared in `pubspec.yaml` under `flutter.assets`
- Load JSON assets via `rootBundle.loadString('assets/psalms.json')` (wrapped in try/catch)
- Do not hardcode asset paths; use the declared asset names

---

## 3. Project Structure

```
lib/
  main.dart          # App entry, routing, screens, AppSettings
  psalm_data.dart    # Data models (Psalm, Verse), repository, utilities
  ad_service.dart    # AdMob initialization and ad loading utilities
  ad_banner_widget.dart # Reusable banner ad widget for Settings/About
assets/
  psalms.json        # All 150 psalms with Amharic text (+ Ge'ez/English where available)
test/
  widget_test.dart  # 19 widget + unit tests
scripts/
  scrape_all_psalms.py  # Web scraper for wordpocket.com (run to refresh data)
  merge_psalms.py       # Merge scraped Amharic with existing Ge'ez/English data
```

### Key Classes
| Class | File | Purpose |
|---|---|---|
| `MezmureDawitApp` | main.dart | Root MaterialApp |
| `SacredMainScaffold` | main.dart | Bottom-nav shell with ad interstitial trigger |
| `SanctuaryHome` | main.dart | Premium home with morning/afternoon/evening prayer sections |
| `_TodayPsalmCard` | main.dart | Today's featured psalm card |
| `_PrayerSection` | main.dart | Horizontal-scroll prayer section (Morning/Midday/Evening) |
| `_PsalmCard` | main.dart | Compact psalm card used inside prayer sections |
| `_PsalmListTile` | main.dart | Psalm row tile used in today's card |
| `LibrarySearchHub` | main.dart | Full psalm index with search + tag filter |
| `FavoritesSanctuary` | main.dart | User's bookmarked psalms |
| `ReadingSanctuary` | main.dart | Verse reader with Amharic/Ge'ez/English toggle |
| `DivineSettings` | main.dart | Dark mode, font size, + banner ad |
| `SacredAbout` | main.dart | About screen with app info + banner ad |
| `AppSettings` | main.dart | Static ValueNotifiers: darkMode, fontSize, favoriteIds |
| `Psalm`, `Verse` | psalm_data.dart | Data models |
| `PsalmRepository` | psalm_data.dart | Static data access + loading |
| `AdService` | ad_service.dart | AdMob SDK init, banner creation, interstitial preloading |
| `AdBannerWidget` | ad_banner_widget.dart | Stateful banner ad widget with auto-load/dispose |

---

## 4. Architecture Notes

- **State:** Simple static `ValueNotifier` singletons in `AppSettings`. No provider/riverpod/state management packages.
- **Data loading:** `main()` awaits `AdService.initialize()` and `PsalmRepository.loadPsalms()` before `runApp()`.
- **No backend:** All data is bundled in `assets/psalms.json` (150 psalms, ~2448 verses, fully trilingual). `_generateMissingData()` only runs if the JSON is missing psalms.
- **Home screen:** `SanctuaryHome` uses `CustomScrollView` with `SliverAppBar` + `SliverToBoxAdapter` sections. Three prayer sections filter by `tags`: "Morning" (psalms 1-41), "Daylight" (42-119), "Evening" (120-150).
- **Extensibility:** New screens are added as stateless widgets and registered in `_SacredMainScaffoldState._pages`.
- **Ad monetization:** `google_mobile_ads` package. Banner ads on Settings + About screens. Interstitial ad shown after every 3 home-screen navigations to other tabs. **No ads in Ge'ez or Amharic reading** (`ReadingSanctuary` with `_lang == "AM"` or `"GE"`). Banner ads shown in English reading mode (`_lang == "EN"`). Replace test ad unit IDs in `ad_service.dart` with real AdMob unit IDs before publishing.

---

## 5. Working in This Repo

- **Never commit** generated files (`build/`, `.dart_tool/`, `.idea/`, `*.lock`, `fetched_psalms.json`, `fetched_awdemehret.json`, `scraped_amharic.json`)
- **Always run** `flutter analyze` after making changes
- **Test** with `flutter test` before pushing
- **Format** with `dart format lib/ test/`
- If adding a new data model, add it in `psalm_data.dart` and mirror it in `psalms.json`
- If adding a new screen, add it to the `_pages` list in `_SacredMainScaffoldState` and add a navigation destination
- Run `python scripts/scrape_all_psalms.py && python scripts/merge_psalms.py` to refresh Amharic psalms from wordpocket.com
- Run `python scripts/scrape_awdemehret.py && python scripts/merge_awdemehret.py` to refresh Ge'ez + English psalms from awdemehret.org
- Replace test ad unit IDs in `ad_service.dart` with real AdMob unit IDs before publishing
