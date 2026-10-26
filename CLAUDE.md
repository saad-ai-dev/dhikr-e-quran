# CLAUDE.md

## Project Overview
Dhikr-e-Quran is a Flutter-based Quran & Dhikr accessibility app focused on Urdu-speaking users. It provides Quran reading with Arabic recitation and Urdu translation audio, 99 Names of Allah, tasbeeh counter, and configurable reminder system.

## Tech Stack
- **Framework:** Flutter 3.24+ (Dart 3.5+)
- **Target Platforms:** Android, Linux Desktop
- **State Management:** StatefulWidget + service injection (no Provider/Bloc)
- **Persistence:** SharedPreferences
- **Audio:** audioplayers + flutter_tts (espeak-ng on Linux)
- **Sharing:** share_plus
- **Haptics:** vibration

## Project Structure
```
lib/
├── main.dart                    # App entry, routes, app-level reminder timer
├── theme/app_theme.dart         # Material 3 theme, colors, text styles
├── localization/app_strings.dart # English/Urdu string maps
├── models/                      # Typed data models (Ayah, AllahName, Surah)
├── services/                    # Business logic (audio, assets, settings, reminders)
├── screens/                     # Full-page screens (splash, home, quran, names, tasbeeh, reminder)
└── widgets/                     # Reusable widgets (ayah_card, feature_card, reminder_popup, settings_sheet)
```

## Build & Run
```bash
export PATH="$PATH:$HOME/flutter/bin"
flutter pub get
flutter run -d linux          # Linux desktop
flutter run                   # Connected Android device
```

## Key Architecture Decisions
- Services created once in `main()` and passed via constructors — no globals or service locators
- Reminder timer lives at app level (`_QuranAppState`) so it fires on any screen
- Audio pipeline: Arabic plays first, then Urdu on completion via `onPlayerComplete` chaining
- All UI strings in `app_strings.dart` keyed by language code ('en'/'ur')
- Audio for 99 Names bundled as assets; Quran audio downloaded from CDN with dual-source fallback

## Audio Sources
- **Arabic Recitation:** Al-Afasy via `cdn.islamic.network` (primary) and `everyayah.com` (fallback)
- **Urdu Translation:** Shamshad Ali Khan (Jalandhri) via `everyayah.com`
- **99 Names:** Pre-generated Google TTS (bundled in assets/audio/names/)

## Conventions
- Dart files use snake_case
- Screens are StatefulWidgets, widgets are StatelessWidgets where possible
- Keep files under 150 lines — split into services/widgets if larger
- Use `AppTheme` constants for all colors/styles — no inline color values
- Use `S.get(key, lang)` for all user-visible strings — no hardcoded text
- Arabic text uses `ScheherazadeNew` font, Urdu uses `NotoNastaliqUrdu`
- Commit messages: imperative mood, first line under 72 chars

## Testing
```bash
flutter test                  # Unit tests
flutter analyze               # Static analysis
```

## Common Tasks
- **Add a new screen:** Create in `lib/screens/`, add route in `main.dart`, add nav in `home_screen.dart`
- **Add localized strings:** Add key to both 'en' and 'ur' maps in `app_strings.dart`
- **Add a new service:** Create in `lib/services/`, instantiate in `main()`, pass via constructors
