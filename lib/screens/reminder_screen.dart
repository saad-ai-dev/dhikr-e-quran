import 'dart:math';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/reminder_service.dart';
import '../widgets/reminder_popup.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';
import '../main.dart';

class ReminderScreen extends StatefulWidget {
  final SettingsService settingsService;
  final AssetManager assetManager;
  final AudioService audioService;

  const ReminderScreen({
    super.key,
    required this.settingsService,
    required this.assetManager,
    required this.audioService,
  });

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late int _interval;
  late ReminderType _type;
  int? _quietStart;
  int? _quietEnd;
  bool _isLoading = true;

  SettingsService get settings => widget.settingsService;
  AssetManager get assets => widget.assetManager;
  AudioService get audio => widget.audioService;
  String get _lang => settings.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _interval = settings.reminderInterval;
    _type = settings.selectedType;
    _quietStart = settings.quietStartHour;
    _quietEnd = settings.quietEndHour;
    _loadData();
  }

  Future<void> _loadData() async {
    if (!assets.isReady) {
      await assets.loadBaseData();
      await assets.loadSurah(1);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _saveAll() {
    settings.reminderInterval = _interval;
    settings.selectedType = _type;
    settings.quietStartHour = _quietStart;
    settings.quietEndHour = _quietEnd;
    QuranApp.restartTimer(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _lang == 'ur' ? 'ترتیبات محفوظ ہو گئیں' : 'Settings saved',
            style: const TextStyle(fontFamily: 'NotoNastaliqUrdu')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.allahNamesAll:
        return _s('allNames');
      case ReminderType.allahNameSingle:
        return _s('specificName');
      case ReminderType.quranRandom:
        return _s('randomVerses');
      case ReminderType.quranSingleVerse:
        return _s('specificVerse');
    }
  }

  String _formatHour(int hour) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $ampm';
  }

  Future<void> _pickHour(bool isStart) async {
    final initial = isStart ? (_quietStart ?? 22) : (_quietEnd ?? 6);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietStart = picked.hour;
        } else {
          _quietEnd = picked.hour;
        }
      });
    }
  }

  void _pickSpecificName() {
    if (assets.allahNames.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_s('selectName'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: assets.allahNames.length,
                itemBuilder: (_, i) {
                  final name = assets.allahNames[i];
                  final isSelected = settings.specificNameIndex == name.id;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: AppTheme.secondaryColor.withOpacity(0.1),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? AppTheme.secondaryColor
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      child: Text('${name.id}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    title: Text(name.arabic,
                        style: AppTheme.arabicBody.copyWith(fontSize: 16)),
                    subtitle: Text(
                        '${name.transliteration} - ${name.urduMeaning}',
                        style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      settings.specificNameIndex = name.id;
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickSpecificVerse() {
    final ayahs = assets.currentSurah?.ayahs ?? [];
    if (ayahs.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_s('selectVerse'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: ayahs.length,
                itemBuilder: (_, i) {
                  final ayah = ayahs[i];
                  final isSelected =
                      settings.specificVerseIndex == ayah.ayahNumber;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: AppTheme.secondaryColor.withOpacity(0.1),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? AppTheme.secondaryColor
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      child: Text('${ayah.ayahNumber}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                    title: Text(ayah.arabicText,
                        style: AppTheme.arabicBody.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(ayah.urduText,
                        style: AppTheme.urduSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onTap: () {
                      settings.specificVerseIndex = ayah.ayahNumber;
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testReminder() {
    if (_isLoading) return;

    switch (_type) {
      case ReminderType.allahNamesAll:
        if (assets.allahNames.isEmpty) return;
        final name = assets.allahNames[0];
        _showNamePopup(name.id);
        break;
      case ReminderType.allahNameSingle:
        if (assets.allahNames.isEmpty) return;
        _showNamePopup(settings.specificNameIndex);
        break;
      case ReminderType.quranRandom:
        final ayahs = assets.currentSurah?.ayahs ?? [];
        if (ayahs.isEmpty) return;
        _showVersePopup(ayahs[Random().nextInt(ayahs.length)]);
        break;
      case ReminderType.quranSingleVerse:
        final ayahs = assets.currentSurah?.ayahs ?? [];
        if (ayahs.isEmpty) return;
        final idx = (settings.specificVerseIndex - 1) % ayahs.length;
        _showVersePopup(ayahs[idx]);
        break;
    }
  }

  void _showNamePopup(int idx) {
    final name = assets.allahNames[(idx - 1) % assets.allahNames.length];
    final closePopup = ReminderPopup.show(
      context,
      arabicText: name.arabic,
      englishText: name.transliteration,
      urduTranslation: name.urduMeaning,
      onDismiss: () => audio.stopAll(),
      lang: _lang,
    );
    audio.playNameAudio(nameIndex: name.id);
    audio.onAllComplete.then((_) => closePopup());
  }

  void _showVersePopup(ayah) {
    final closePopup = ReminderPopup.show(
      context,
      arabicText: ayah.arabicText,
      urduTranslation: ayah.urduText,
      onDismiss: () => audio.stopAll(),
      lang: _lang,
    );
    audio.playVerseWithTranslation(
      arabicAudioPath: assets.arabicAudioPaths[ayah.ayahNumber],
      urduAudioPath: assets.urduAudioPaths[ayah.ayahNumber],
    );
    audio.onAllComplete.then((_) => closePopup());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_s('reminders'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current status card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_s('currentStatus'),
                          style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _statusRow(Icons.timer_outlined,
                          '${_s('reminderEvery')} $_interval ${_s('minutes')}'),
                      const SizedBox(height: 6),
                      _statusRow(Icons.category_outlined, _typeLabel(_type)),
                      const SizedBox(height: 6),
                      _statusRow(
                          Icons.nights_stay_outlined,
                          _quietStart != null && _quietEnd != null
                              ? '${_formatHour(_quietStart!)} - ${_formatHour(_quietEnd!)}'
                              : _s('quietNotSet')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interval slider — starts at 1 minute
                _sectionTitle(_s('intervalLabel')),
                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 ${_s('minutes')}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted)),
                            Text('$_interval ${_s('minutes')}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryColor)),
                            Text('60 ${_s('minutes')}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                        Slider(
                          value: _interval.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          activeColor: AppTheme.secondaryColor,
                          onChanged: (v) =>
                              setState(() => _interval = v.round()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quiet hours
                _sectionTitle(_s('quietHours')),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.bedtime_outlined, size: 16),
                            label: Text(
                                _quietStart != null
                                    ? _formatHour(_quietStart!)
                                    : _s('quietStart'),
                                style: const TextStyle(fontSize: 13)),
                            onPressed: () => _pickHour(true),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('→',
                              style: TextStyle(color: AppTheme.textMuted)),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                            label: Text(
                                _quietEnd != null
                                    ? _formatHour(_quietEnd!)
                                    : _s('quietEnd'),
                                style: const TextStyle(fontSize: 13)),
                            onPressed: () => _pickHour(false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reminder content type
                _sectionTitle(_s('reminderContent')),
                Card(
                  child: Column(
                    children: [
                      _typeRadio(
                          ReminderType.allahNamesAll, Icons.star_rounded),
                      _typeRadio(ReminderType.allahNameSingle,
                          Icons.star_half_rounded),
                      // Show pick button when specific name selected
                      if (_type == ReminderType.allahNameSingle)
                        _selectedItemTile(
                          assets.allahNames.isNotEmpty
                              ? '${assets.allahNames[(settings.specificNameIndex - 1) % assets.allahNames.length].arabic} (${assets.allahNames[(settings.specificNameIndex - 1) % assets.allahNames.length].transliteration})'
                              : _s('selectName'),
                          onTap: _pickSpecificName,
                        ),
                      _typeRadio(
                          ReminderType.quranRandom, Icons.shuffle_rounded),
                      _typeRadio(ReminderType.quranSingleVerse,
                          Icons.bookmark_rounded),
                      // Show pick button when specific verse selected
                      if (_type == ReminderType.quranSingleVerse)
                        _selectedItemTile(
                          (assets.currentSurah?.ayahs.isNotEmpty ?? false)
                              ? '${_s('ayah')} ${settings.specificVerseIndex}'
                              : _s('selectVerse'),
                          onTap: _pickSpecificVerse,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Test, Save, Cancel buttons
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(_s('testReminder')),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44)),
                  onPressed: _testReminder,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44)),
                        child: Text(_lang == 'ur' ? 'منسوخ' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saveAll();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44)),
                        child: Text(_s('savePreferences')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor)),
    );
  }

  Widget _statusRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }

  Widget _typeRadio(ReminderType type, IconData icon) {
    return RadioListTile<ReminderType>(
      value: type,
      groupValue: _type,
      dense: true,
      secondary: Icon(icon,
          size: 18,
          color: _type == type ? AppTheme.secondaryColor : AppTheme.textMuted),
      title: Text(_typeLabel(type), style: const TextStyle(fontSize: 13)),
      onChanged: (v) => setState(() => _type = v!),
    );
  }

  Widget _selectedItemTile(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 12, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(text,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.secondaryColor))),
              const Icon(Icons.edit, size: 14, color: AppTheme.secondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
