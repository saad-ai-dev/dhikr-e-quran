import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class SalahTrackerScreen extends StatefulWidget {
  final SettingsService settingsService;

  const SalahTrackerScreen({super.key, required this.settingsService});

  @override
  State<SalahTrackerScreen> createState() => _SalahTrackerScreenState();
}

class _SalahTrackerScreenState extends State<SalahTrackerScreen> {
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _prayersUr = ['فجر', 'ظہر', 'عصر', 'مغرب', 'عشاء'];
  static const _prayerIcons = [
    Icons.nights_stay_rounded,
    Icons.wb_sunny_rounded,
    Icons.sunny_snowing,
    Icons.wb_twilight,
    Icons.dark_mode_rounded,
  ];

  final Map<String, bool> _completed = {};
  int _streak = 0;

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey;
    setState(() {
      for (final prayer in _prayers) {
        _completed[prayer] = prefs.getBool('salah_${today}_$prayer') ?? false;
      }
      _streak = prefs.getInt('salah_streak') ?? 0;

      // Check if yesterday was complete to maintain streak
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      final yesterdayComplete =
          _prayers.every((p) => prefs.getBool('salah_${yKey}_$p') ?? false);
      final todayStarted = _completed.values.any((v) => v);

      if (!yesterdayComplete && !todayStarted && _streak > 0) {
        _streak = 0;
        prefs.setInt('salah_streak', 0);
      }
    });
  }

  Future<void> _togglePrayer(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey;
    final newValue = !(_completed[prayer] ?? false);

    setState(() => _completed[prayer] = newValue);
    await prefs.setBool('salah_${today}_$prayer', newValue);

    // Check if all prayers complete today
    final allComplete = _prayers.every((p) => _completed[p] ?? false);
    if (allComplete) {
      final currentStreak = prefs.getInt('salah_streak') ?? 0;
      final lastCompleteDate = prefs.getString('salah_last_complete') ?? '';
      if (lastCompleteDate != today) {
        setState(() => _streak = currentStreak + 1);
        await prefs.setInt('salah_streak', _streak);
        await prefs.setString('salah_last_complete', today);
      }
    }
  }

  int get _completedCount => _completed.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_s('salahTracker'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  _lang == 'ur' ? 'آج کی نمازیں' : "Today's Prayers",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                const SizedBox(height: 12),
                // Circular progress
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _completedCount / 5,
                        strokeWidth: 6,
                        backgroundColor: Colors.white12,
                        color: AppTheme.accentGold,
                      ),
                      Text(
                        '$_completedCount/5',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 16, color: AppTheme.accentGold),
                    const SizedBox(width: 4),
                    Text(
                      '$_streak ${_lang == 'ur' ? 'دن کا سلسلہ' : 'day streak'}',
                      style: const TextStyle(
                          color: AppTheme.accentGold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Prayer list
          ...List.generate(_prayers.length, (i) {
            final prayer = _prayers[i];
            final done = _completed[prayer] ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: done ? AppTheme.secondaryColor.withOpacity(0.08) : null,
              child: ListTile(
                leading: Icon(
                  _prayerIcons[i],
                  size: 22,
                  color: done ? AppTheme.secondaryColor : AppTheme.textMuted,
                ),
                title: Text(
                  _lang == 'ur' ? _prayersUr[i] : prayer,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: done ? FontWeight.bold : FontWeight.normal,
                    color: done ? AppTheme.secondaryColor : AppTheme.textDark,
                    fontFamily: _lang == 'ur' ? 'NotoNastaliqUrdu' : null,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    done ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: done ? AppTheme.secondaryColor : AppTheme.textMuted,
                    size: 28,
                  ),
                  onPressed: () => _togglePrayer(prayer),
                ),
                onTap: () => _togglePrayer(prayer),
              ),
            );
          }),
        ],
      ),
    );
  }
}
