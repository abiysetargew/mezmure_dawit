# Mezmure Dawit — መዝሙረ ዳዊት

A Flutter Android app presenting the 150 psalms of David in **Ge'ez**, **Amharic**, and **English** — built for daily prayer and meditation.

## Features

- 150 psalms with day-of-the-week prayer schedule (Orthodox week)
- Trilingual reader with per-verse language toggle (አማርኛ / ግዕዝ / English)
- Morning, Midday and Evening prayer collections
- Search and tag filters across the full index
- Favorites, dark/light themes, adjustable reading font size
- Google Mobile Ads (banner + interstitial; Amharic/Ge'ez reading is ad-free)

## Development

```bash
flutter pub get
flutter run
```

### Verify

```bash
flutter analyze   # must report "No issues found!"
flutter test      # unit + widget tests
```

### Build

```bash
flutter build apk --release   # signed with android/upload-keystore.jks via android/key.properties
```

Release signing requires `android/key.properties` (git-ignored) pointing at your upload keystore. The committed build config falls back to debug keys only when key.properties is absent.

## Data

`assets/psalms.json` — 150 psalms, ~3,374 verses. Some verses are not yet available in all three languages; the reader shows "Translation not available" for missing text. Scrape/merge scripts live in `scripts/`.

## Publishing checklist

- [ ] Replace Google's **test** AdMob unit IDs in `lib/ad_service_mobile.dart` with production unit IDs
- [ ] Replace the **test** AdMob App ID in `android/app/src/main/AndroidManifest.xml` with your real App ID
- [ ] Back up `android/upload-keystore.jks` + `android/key.properties` (passwords are only on this machine)
- [ ] Promote the version in `pubspec.yaml` (`version: 1.0.8+8`)

See `AGENTS.md` for architecture notes.
