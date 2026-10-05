import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/asset_manager.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/names_screen.dart';

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

class QuranApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran & Dhikr',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen(
              assetManager: assetManager,
              audioService: audioService,
              settingsService: settingsService,
            ));
          case '/quran':
            return MaterialPageRoute(builder: (_) => QuranScreen(
              assetManager: assetManager,
              audioService: audioService,
              settingsService: settingsService,
            ));
          case '/names':
            return MaterialPageRoute(builder: (_) => NamesScreen(
              assetManager: assetManager,
              audioService: audioService,
            ));
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
