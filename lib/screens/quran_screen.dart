import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../widgets/ayah_card.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class QuranScreen extends StatefulWidget {
  final AssetManager assetManager;
  final AudioService audioService;
  final SettingsService settingsService;
  final int surahNumber;

  const QuranScreen({
    super.key,
    required this.assetManager,
    required this.audioService,
    required this.settingsService,
    this.surahNumber = 1,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  bool _isLoading = true;
  String _statusMessage = '';
  Surah? _surah;

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  AssetManager get assets => widget.assetManager;
  AudioService get audio => widget.audioService;
  SettingsService get settings => widget.settingsService;

  @override
  void initState() {
    super.initState();
    _statusMessage = _s('initializing');
    _loadSurah();
  }

  @override
  void dispose() {
    audio.stopAll();
    super.dispose();
  }

  Future<void> _loadSurah() async {
    await assets.loadBaseData();
    _surah = await assets.loadSurah(
      widget.surahNumber,
      onProgress: (msg) {
        if (mounted) setState(() => _statusMessage = msg);
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  void _playAyah(Ayah ayah) {
    audio.playVerseWithTranslation(
      arabicAudioPath: assets.arabicAudioPaths[ayah.ayahNumber],
      urduAudioPath: assets.urduAudioPaths[ayah.ayahNumber],
    );
  }

  void _copyAyah(Ayah ayah) {
    final name = _surah?.nameArabic ?? '';
    final ref = '$name - ${_s('ayah')} ${ayah.ayahNumber}';
    Clipboard.setData(
        ClipboardData(text: '${ayah.arabicText}\n\n${ayah.urduText}\n\n$ref'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_s('ayah')} ${ayah.ayahNumber} ${_s('ayahCopied')}',
            style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAyah(Ayah ayah) async {
    final name = _surah?.nameArabic ?? '';
    final ref = '$name - ${_s('ayah')} ${ayah.ayahNumber}';
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
          _surah != null
              ? '${_surah!.nameArabic} - ${_surah!.nameEnglish}'
              : _s('quranPak'),
          style: const TextStyle(fontFamily: 'ScheherazadeNew', fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => SettingsBottomSheet.show(
              context,
              settings: settings,
              onChanged: () {},
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
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _surah!.ayahs.length,
              itemBuilder: (_, i) {
                final ayah = _surah!.ayahs[i];
                return AyahCard(
                  ayah: ayah,
                  lang: _lang,
                  onTap: () => _playAyah(ayah),
                  onCopy: () => _copyAyah(ayah),
                  onShare: () => _shareAyah(ayah),
                );
              },
            ),
    );
  }
}
