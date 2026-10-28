import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/asset_manager.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'services/reminder_service.dart';
import 'widgets/reminder_popup.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/names_screen.dart';
import 'screens/tasbeeh_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/dua_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.create();
  final audioService = AudioService();
  final assetManager = AssetManager();

  await SettingsService.requestAppPermissions();

  runApp(QuranApp(
    settingsService: settingsService,
    audioService: audioService,
    assetManager: assetManager,
  ));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class QuranApp extends StatefulWidget {
  final SettingsService settingsService;
  final AudioService audioService;
  final AssetManager assetManager;

  const QuranApp({
    super.key,
    required this.settingsService,
    required this.audioService,
    required this.assetManager,
  });

  @override
  State<QuranApp> createState() => _QuranAppState();

  static void restartTimer(BuildContext context) {
    context.findAncestorStateOfType<_QuranAppState>()?._startTimer();
  }
}

class _QuranAppState extends State<QuranApp> {
  Timer? _reminderTimer;

  SettingsService get settings => widget.settingsService;
  AssetManager get assets => widget.assetManager;
  AudioService get audio => widget.audioService;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      Duration(minutes: settings.reminderInterval),
      (_) => _triggerReminder(),
    );
  }

  Future<void> _triggerReminder() async {
    if (await ReminderService.isQuietHoursActive()) return;
    if (!assets.isReady) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    final type = settings.selectedType;
    final lang = settings.language;

    if (type == ReminderType.allahNamesAll) {
      int idx = await ReminderService.getNextNameIndex();
      _showNameReminder(ctx, idx, lang);
    } else if (type == ReminderType.allahNameSingle) {
      _showNameReminder(ctx, settings.specificNameIndex, lang);
    } else if (type == ReminderType.quranRandom) {
      final ayahs = assets.surahData!.ayahs;
      _showVerseReminder(ctx, ayahs[Random().nextInt(ayahs.length)], lang);
    } else if (type == ReminderType.quranSingleVerse) {
      final idx =
          (settings.specificVerseIndex - 1) % assets.surahData!.ayahs.length;
      _showVerseReminder(ctx, assets.surahData!.ayahs[idx], lang);
    }
  }

  void _showNameReminder(BuildContext ctx, int idx, String lang) {
    var name = assets.allahNames[(idx - 1) % assets.allahNames.length];
    final closePopup = ReminderPopup.show(
      ctx,
      arabicText: name.arabic,
      englishText: name.transliteration,
      urduTranslation: name.urduMeaning,
      onDismiss: () => audio.stopAll(),
      lang: lang,
    );
    audio.playNameAudio(nameIndex: name.id);
    audio.onAllComplete.then((_) => closePopup());
  }

  void _showVerseReminder(BuildContext ctx, ayah, String lang) {
    final closePopup = ReminderPopup.show(
      ctx,
      arabicText: ayah.arabicText,
      urduTranslation: ayah.urduText,
      onDismiss: () => audio.stopAll(),
      lang: lang,
    );
    audio.playVerseWithTranslation(
      arabicAudioPath: assets.arabicAudioPaths[ayah.ayahNumber],
      urduAudioPath: assets.urduAudioPaths[ayah.ayahNumber],
    );
    audio.onAllComplete.then((_) => closePopup());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran & Dhikr',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(
                builder: (_) => HomeScreen(
                      assetManager: assets,
                      audioService: audio,
                      settingsService: settings,
                    ));
          case '/quran':
            return MaterialPageRoute(
                builder: (_) => QuranScreen(
                      assetManager: assets,
                      audioService: audio,
                      settingsService: settings,
                    ));
          case '/names':
            return MaterialPageRoute(
                builder: (_) => NamesScreen(
                      assetManager: assets,
                      audioService: audio,
                    ));
          case '/tasbeeh':
            return MaterialPageRoute(
                builder: (_) => TasbeehScreen(
                      settingsService: settings,
                    ));
          case '/duas':
            return MaterialPageRoute(
                builder: (_) => DuaScreen(
                      settingsService: settings,
                    ));
          case '/reminder':
            return MaterialPageRoute(
                builder: (_) => ReminderScreen(
                      settingsService: settings,
                      assetManager: assets,
                      audioService: audio,
                    ));
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
