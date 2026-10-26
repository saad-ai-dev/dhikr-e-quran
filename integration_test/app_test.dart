import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_urdu_app/main.dart';
import 'package:quran_urdu_app/services/settings_service.dart';
import 'package:quran_urdu_app/services/audio_service.dart';
import 'package:quran_urdu_app/services/asset_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App E2E Tests', () {
    late SettingsService settingsService;
    late AudioService audioService;
    late AssetManager assetManager;

    setUp(() async {
      settingsService = await SettingsService.create();
      audioService = AudioService();
      assetManager = AssetManager();
    });

    testWidgets('Splash screen navigates to home', (tester) async {
      await tester.pumpWidget(QuranApp(
        settingsService: settingsService,
        audioService: audioService,
        assetManager: assetManager,
      ));

      // Splash screen should be visible
      expect(find.text('القرآن الکریم'), findsOneWidget);

      // Wait for navigation to home (3 seconds + animation)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Home screen should be visible
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Home screen shows feature cards', (tester) async {
      await tester.pumpWidget(QuranApp(
        settingsService: settingsService,
        audioService: audioService,
        assetManager: assetManager,
      ));

      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should see feature cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Navigate to Quran screen', (tester) async {
      await tester.pumpWidget(QuranApp(
        settingsService: settingsService,
        audioService: audioService,
        assetManager: assetManager,
      ));

      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Tap the Quran feature card (first card)
      final cards = find.byType(Card);
      await tester.tap(cards.first);
      await tester.pumpAndSettle();

      // Should see loading or ayah list
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Navigate to Tasbeeh screen', (tester) async {
      await tester.pumpWidget(QuranApp(
        settingsService: settingsService,
        audioService: audioService,
        assetManager: assetManager,
      ));

      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Find and tap tasbeeh card
      final cards = find.byType(Card);
      if (cards.evaluate().length >= 3) {
        await tester.tap(cards.at(2));
        await tester.pumpAndSettle();
      }
    });

    tearDown(() {
      audioService.dispose();
    });
  });
}
