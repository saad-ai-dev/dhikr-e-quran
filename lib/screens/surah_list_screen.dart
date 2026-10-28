import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class SurahListScreen extends StatefulWidget {
  final AssetManager assetManager;
  final AudioService audioService;
  final SettingsService settingsService;

  const SurahListScreen({
    super.key,
    required this.assetManager,
    required this.audioService,
    required this.settingsService,
  });

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  bool _isLoading = true;
  String _searchQuery = '';

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    await widget.assetManager.loadBaseData();
    if (mounted) setState(() => _isLoading = false);
  }

  List<SurahMeta> get _filteredSurahs {
    if (_searchQuery.isEmpty) return widget.assetManager.surahIndex;
    final q = _searchQuery.toLowerCase();
    return widget.assetManager.surahIndex.where((s) {
      return s.nameEnglish.toLowerCase().contains(q) ||
          s.nameArabic.contains(_searchQuery) ||
          s.number.toString() == q;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s('quranPak')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _s('search') ?? 'Search surah...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredSurahs.length,
                    itemBuilder: (_, i) {
                      final surah = _filteredSurahs[i];
                      return _SurahTile(
                        surah: surah,
                        lang: _lang,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/quran',
                          arguments: surah.number,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahMeta surah;
  final String lang;
  final VoidCallback onTap;

  const _SurahTile({
    required this.surah,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: Text('${surah.number}',
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          surah.nameArabic,
          textAlign: TextAlign.right,
          style: AppTheme.arabicBody.copyWith(fontSize: 16),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${surah.totalAyahs} ${S.get('ayah', lang)}  •  ${surah.revelationType}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            Text(
              surah.nameEnglish,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right,
            size: 18, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
