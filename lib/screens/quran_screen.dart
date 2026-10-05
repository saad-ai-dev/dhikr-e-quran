import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ayah.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../services/reminder_service.dart';
import '../widgets/ayah_card.dart';
import '../widgets/reminder_popup.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../theme/app_theme.dart';

class QuranScreen extends StatefulWidget {
  final AssetManager assetManager;
  final AudioService audioService;
  final SettingsService settingsService;

  const QuranScreen({
    super.key,
    required this.assetManager,
    required this.audioService,
    required this.settingsService,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  bool _isLoading = true;
  String _statusMessage = "Initializing...";
  Timer? _reminderTimer;

  AssetManager get assets => widget.assetManager;
  AudioService get audio => widget.audioService;
  SettingsService get settings => widget.settingsService;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startReminderTimer();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    audio.stopAll();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (assets.isReady) {
      setState(() => _isLoading = false);
      return;
    }
    await assets.loadAllData(onProgress: (msg) {
      if (mounted) setState(() => _statusMessage = msg);
    });
    if (mounted) setState(() => _isLoading = false);
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      Duration(minutes: settings.reminderInterval),
      (_) => _triggerReminder(),
    );
  }

  Future<void> _triggerReminder() async {
    if (await ReminderService.isQuietHoursActive()) return;

    if (settings.selectedType == ReminderType.allahNames) {
      int idx = await ReminderService.getNextNameIndex();
      var name = assets.allahNames[(idx - 1) % assets.allahNames.length];

      ReminderPopup.show(context,
        arabicText: name.arabic,
        englishText: name.transliteration,
        urduTranslation: name.urduMeaning,
        onDismiss: () => audio.stopAll(),
      );
      await audio.playNameAudio(nameIndex: idx);
    } else {
      int globalIdx = await ReminderService.getNextVerseIndex(6236);
      int localIdx = (globalIdx - 1) % assets.surahData!.ayahs.length;
      Ayah ayah = assets.surahData!.ayahs[localIdx];

      ReminderPopup.show(context,
        arabicText: ayah.arabicText,
        urduTranslation: ayah.urduText,
        onDismiss: () => audio.stopAll(),
      );
      _playAyah(ayah);
    }
  }

  void _playAyah(Ayah ayah) {
    audio.playVerseWithTranslation(
      arabicAudioPath: assets.arabicAudioPaths[ayah.ayahNumber],
      urduAudioPath: assets.urduAudioPaths[ayah.ayahNumber],
    );
  }

  void _copyAyah(Ayah ayah) {
    final ref = '${assets.surahData!.nameUrdu} - آیت ${ayah.ayahNumber}';
    Clipboard.setData(ClipboardData(text: '${ayah.arabicText}\n\n${ayah.urduText}\n\n$ref'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('آیت ${ayah.ayahNumber} کاپی ہو گئی', style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAyah(Ayah ayah) async {
    final ref = '${assets.surahData!.nameUrdu} - آیت ${ayah.ayahNumber}';
    final text = '${ayah.arabicText}\n\n${ayah.urduText}\n\n$ref';
    final List<XFile> files = [];

    final arPath = assets.arabicAudioPaths[ayah.ayahNumber];
    if (arPath != null && await File(arPath).exists()) {
      files.add(XFile(arPath, mimeType: 'audio/mpeg'));
    }
    final urPath = assets.urduAudioPaths[ayah.ayahNumber];
    if (urPath != null && await File(urPath).exists()) {
      files.add(XFile(urPath, mimeType: 'audio/mpeg'));
    }

    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: text, subject: ref);
    } else {
      await Share.share(text, subject: ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          assets.isReady ? assets.surahData!.nameUrdu : 'قرآن پاک',
          style: const TextStyle(fontFamily: 'NotoNastaliqUrdu'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => SettingsBottomSheet.show(context,
              settings: settings,
              onChanged: _startReminderTimer,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_statusMessage, style: AppTheme.urduSubtitle),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Reminder: Every ${settings.reminderInterval} mins",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.notifications_active, size: 18),
                        label: const Text("Test"),
                        onPressed: _triggerReminder,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: assets.surahData!.ayahs.length,
                    itemBuilder: (_, i) {
                      final ayah = assets.surahData!.ayahs[i];
                      return AyahCard(
                        ayah: ayah,
                        onTap: () => _playAyah(ayah),
                        onCopy: () => _copyAyah(ayah),
                        onShare: () => _shareAyah(ayah),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
