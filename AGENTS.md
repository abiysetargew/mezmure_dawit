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
- **Private members:** Leading `_` (e.g., `_idx`, `_verseAdMilestone`)
- **Constants:** `camelCase` or `kebab-case` in ValueNotifier names (current project uses `camelCase`)
- **Files:** `snake_case.dart`

#### Error Handling
- Use `try/catch` with specific handling; avoid bare `catch (_)` except where errors are intentionally ignored. `PsalmRepository.loadPsalms()` records failures in `PsalmRepository.loadError` and the app shows a data-error screen instead of fabricating content.
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
  ad_service.dart    # Conditional export: ad_service_stub.dart (web/test) or ad_service_mobile.dart (io)
  ad_service_mobile.dart # AdMob init, banner creation, interstitial lifecycle (loads at startup, reloads on dismiss)
  ad_banner_widget.dart  # Conditional export: ad_banner_widget_stub.dart or ad_banner_widget_mobile.dart
  app_theme.dart     # Dark/light ThemeData (Material 3)
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
| `DivineSettings` | main.dart | Dark mode, font size |
| `SacredAbout` | main.dart | About screen |
| `AppSettings` | main.dart | Static ValueNotifiers: darkMode, fontSize, favoriteIds |
| `Psalm`, `Verse` | psalm_data.dart | Data models |
| `PsalmRepository` | psalm_data.dart | Static data access + loading |
| `AdService` | ad_service.dart | AdMob SDK init, banner creation, interstitial preloading |
| `AdBannerWidget` | ad_banner_widget.dart | Stateful banner ad widget with auto-load/dispose |

---

## 4. Architecture Notes

- **State:** Simple static `ValueNotifier` singletons in `AppSettings`. No provider/riverpod/state management packages.
- **Data loading:** `main()` awaits `AdService.initialize()` and `PsalmRepository.loadPsalms()` before `runApp()`.
- **No backend:** All data is bundled in `assets/psalms.json` (150 psalms, 3,374 verses). Verse coverage is not yet complete in all three languages — the reader shows "Translation not available" for missing verses. If the asset fails to load, `PsalmRepository.loadError` is set and the app shows a data-error screen rather than fabricating content.
- **Home screen:** `SanctuaryHome` uses `CustomScrollView` with `SliverAppBar` + `SliverToBoxAdapter` sections. Three prayer sections filter by `tags`: "Morning" (psalms 1-41), "Daylight" (42-119), "Evening" (120-150).
- **Extensibility:** New screens are added as stateless widgets and registered in `_SacredMainScaffoldState._pages`.
- **Ad monetization:** `google_mobile_ads` package. **Currently Google's TEST ad unit IDs** (safe to click) — in `lib/ad_service_mobile.dart` and the APPLICATION_ID meta-data in `android/app/src/main/AndroidManifest.xml`. Replace with production unit IDs before publishing. Banner ads appear on Home, Index, Favorites, and English reading mode; interstitial after every 3 home-screen tab switches; in English reading, interstitials at 25%/50%/75% scroll milestones (max 3 per session, font-size independent). **No ads in Ge'ez or Amharic reading.** Interstitials preload in `AdService.initialize()` and reload after each dismiss.
- **Release signing:** `android/app/build.gradle.kts` loads `android/key.properties` (git-ignored) for the `upload` keystore (`android/upload-keystore.jks`, git-ignored). Falls back to debug signing only when key.properties is missing. Package name is `com.mezmuredawit.app`. Version is `1.0.8+8`.

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
- Replace Google's test AdMob unit IDs (`lib/ad_service_mobile.dart`) and test APPLICATION_ID (`android/app/src/main/AndroidManifest.xml`) with real IDs before publishing
- Back up `android/upload-keystore.jks` + `android/key.properties`; losing them prevents future updates
