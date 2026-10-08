# Dhikr-e-Quran

A modern Quran & Dhikr accessibility app built with Flutter, designed for Urdu-speaking users with a focus on audio-first Islamic content delivery.

## Features

### Quran Reading & Listening
- Arabic text with proper Scheherazade font rendering
- Human voice Arabic recitation (Mishary Al-Afasy)
- Human voice Urdu translation (Shamshad Ali Khan - Jalandhri)
- Sequential audio pipeline: Arabic recitation plays, then Urdu translation follows
- Dual-CDN audio download with automatic fallback
- Copy and share ayah with reference and audio files

### 99 Names of Allah (Asma ul Husna)
- Browse all 99 Names with Arabic, transliteration, and Urdu meaning
- Individual audio for each name (Arabic pronunciation + Urdu meaning)
- Copy and share functionality for each name

### Tasbeeh Counter
- Digital dhikr counter with clean minimal UI
- Haptic vibration feedback at milestones (33 and 100)
- Counter persists across app sessions
- Reset with confirmation dialog

### Smart Reminder System
- Configurable interval timer (1-60 minutes)
- 4 content modes: All 99 Names, Specific Name, Random Verse, Specific Verse
- In-app popup overlay with audio playback
- Auto-dismiss after audio completes
- Quiet hours configuration (no reminders during sleep)
- Works on any screen — app-level timer

### Localization
- Full English/Urdu language toggle
- All UI strings localized
- Arabic Quranic text remains unchanged in both modes

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter 3.24+ |
| Language | Dart 3.5+ |
| Audio | audioplayers 6.x |
| TTS | flutter_tts (Android), espeak-ng (Linux) |
| Storage | SharedPreferences |
| Sharing | share_plus |
| Haptics | vibration |
| Design | Material 3 |

## Getting Started

### Prerequisites
- Flutter SDK 3.24+
- Android SDK (for Android builds)
- Linux desktop dependencies (for Linux builds):
  ```bash
  sudo apt install clang cmake ninja-build libgtk-3-dev liblzma-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
  ```

### Installation
```bash
git clone https://github.com/saad-ai-dev/dhikr-e-quran.git
cd dhikr-e-quran
flutter pub get
```

### Run
```bash
# Linux Desktop
flutter run -d linux

# Android (connected device)
flutter run

# Build APK
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                          # App entry, routing, app-level reminder timer
├── theme/
│   └── app_theme.dart                 # Material 3 theme configuration
├── localization/
│   └── app_strings.dart               # English/Urdu string maps
├── models/
│   ├── ayah.dart                      # Quran verse data model
│   ├── allah_name.dart                # 99 Names data model
│   └── surah.dart                     # Surah wrapper model
├── services/
│   ├── audio_service.dart             # Audio playback + TTS engine
│   ├── asset_manager.dart             # Data loading + CDN download
│   ├── reminder_service.dart          # Reminder sequence + quiet hours
│   └── settings_service.dart          # Preferences persistence
├── screens/
│   ├── splash_screen.dart             # Animated landing screen
│   ├── home_screen.dart               # Feature grid + bottom nav
│   ├── quran_screen.dart              # Quran reading with audio
│   ├── names_screen.dart              # 99 Names browsing
│   ├── tasbeeh_screen.dart            # Dhikr counter
│   └── reminder_screen.dart           # Reminder configuration
└── widgets/
    ├── ayah_card.dart                 # Verse display card
    ├── feature_card.dart              # Home page feature tile
    ├── reminder_popup.dart            # Reminder dialog
    └── settings_bottom_sheet.dart     # Settings modal
```

## Audio Sources

| Content | Source | Quality |
|---|---|---|
| Arabic Recitation | cdn.islamic.network (Al-Afasy) | 128kbps |
| Arabic Fallback | everyayah.com (Al-Afasy) | 128kbps |
| Urdu Translation | everyayah.com (Shamshad Ali Khan) | 46kbps |
| 99 Names Audio | Pre-generated Google TTS | Bundled |

## Roadmap

See [open issues](https://github.com/saad-ai-dev/dhikr-e-quran/issues) for planned features and [project board](https://github.com/users/saad-ai-dev/projects/4) for progress tracking.

### Upcoming Milestones
- **v1.0** — Complete Quran, Prayer Times, Qibla, Dua Collection, Salah Tracker
- **v1.1** — Hadith, Bookmarks, Search, Daily Verse, Multiple Reciters, Dark Mode
- **v1.2** — Tafsir, Islamic Calendar, Mosque Locator, Image Sharing, Multiple Translations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
