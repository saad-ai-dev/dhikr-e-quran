import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/allah_name.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class NamesScreen extends StatefulWidget {
  final AssetManager assetManager;
  final AudioService audioService;

  const NamesScreen({
    super.key,
    required this.assetManager,
    required this.audioService,
  });

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  int? _playingId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.assetManager.isReady) {
      setState(() => _isLoading = false);
      return;
    }
    await widget.assetManager.loadAllData(onProgress: (_) {});
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    widget.audioService.stopAll();
    super.dispose();
  }

  void _playName(AllahName name) async {
    setState(() => _playingId = name.id);
    await widget.audioService.playNameAudio(nameIndex: name.id);
  }

  void _copyName(AllahName name) {
    final text = '${name.arabic}\n${name.transliteration}\n${name.urduMeaning}\n\nاسماء الحسنیٰ - ${name.id}/99';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${name.transliteration} کاپی ہو گیا', style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareName(AllahName name) async {
    final text = '${name.arabic}\n${name.transliteration}\n${name.urduMeaning}\n\nاسماء الحسنیٰ - ${name.id}/99';
    final List<XFile> files = [];

    // Copy bundled asset audio to temp for sharing
    final tempDir = await getTemporaryDirectory();
    for (final suffix in ['ar', 'ur']) {
      try {
        final assetData = await rootBundle.load('assets/audio/names/name_${name.id}_$suffix.mp3');
        final tempFile = File('${tempDir.path}/name_${name.id}_$suffix.mp3');
        await tempFile.writeAsBytes(assetData.buffer.asUint8List());
        files.add(XFile(tempFile.path, mimeType: 'audio/mpeg'));
      } catch (_) {}
    }

    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: text, subject: '${name.transliteration} - اسماء الحسنیٰ');
    } else {
      await Share.share(text, subject: '${name.transliteration} - اسماء الحسنیٰ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسماء الحسنیٰ', style: TextStyle(fontFamily: 'NotoNastaliqUrdu', fontSize: 22)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.assetManager.allahNames.length,
              itemBuilder: (_, i) {
                final name = widget.assetManager.allahNames[i];
                final isPlaying = _playingId == name.id;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  color: isPlaying ? AppTheme.primaryColor.withOpacity(0.08) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: number + action buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              child: Text('${name.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(height: 6),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.secondaryColor),
                              tooltip: 'نقل کریں',
                              onPressed: () => _copyName(name),
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_rounded, size: 16, color: AppTheme.secondaryColor),
                              tooltip: 'شیئر کریں',
                              onPressed: () => _shareName(name),
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // Center: name text
                        Expanded(
                          child: InkWell(
                            onTap: () => _playName(name),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(name.arabic, textAlign: TextAlign.right, style: AppTheme.arabicBody),
                                const SizedBox(height: 6),
                                Text(name.transliteration, textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 16, color: AppTheme.secondaryColor)),
                                const SizedBox(height: 4),
                                Text(name.urduMeaning, textAlign: TextAlign.right, style: AppTheme.urduSubtitle),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Right: play button
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                          onPressed: () => _playName(name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
