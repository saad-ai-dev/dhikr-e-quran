import 'package:flutter/material.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class PrayerTimesScreen extends StatefulWidget {
  final SettingsService settingsService;

  const PrayerTimesScreen({super.key, required this.settingsService});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  List<PrayerTime> _prayers = [];
  PrayerTime? _nextPrayer;
  bool _isLoading = true;
  String _error = '';

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final position = await PrayerService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _isLoading = false;
        _error = _lang == 'ur'
            ? 'مقام کی اجازت درکار ہے'
            : 'Location permission required';
      });
      return;
    }

    final prayers = await PrayerService.fetchPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (mounted) {
      setState(() {
        _prayers = prayers;
        _nextPrayer = PrayerService.getNextPrayer(prayers);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s('prayerTimes')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off,
                          size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text(_error,
                          style: const TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrayerTimes,
                        child: Text(_s('retry')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrayerTimes,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Next prayer card
                      if (_nextPrayer != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _lang == 'ur' ? 'اگلی نماز' : 'Next Prayer',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _lang == 'ur'
                                    ? _nextPrayer!.nameUrdu
                                    : _nextPrayer!.name,
                                style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoNastaliqUrdu'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _nextPrayer!.time,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      // All prayer times
                      ..._prayers.map((prayer) => _PrayerTile(
                            prayer: prayer,
                            isNext: prayer.name == _nextPrayer?.name,
                            lang: _lang,
                          )),
                    ],
                  ),
                ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;
  final String lang;

  const _PrayerTile({
    required this.prayer,
    required this.isNext,
    required this.lang,
  });

  IconData get _icon {
    switch (prayer.name) {
      case 'Fajr':
        return Icons.nights_stay_rounded;
      case 'Sunrise':
        return Icons.wb_twilight_rounded;
      case 'Dhuhr':
        return Icons.wb_sunny_rounded;
      case 'Asr':
        return Icons.sunny_snowing;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isha':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isNext ? AppTheme.secondaryColor.withOpacity(0.08) : null,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(_icon,
            size: 20,
            color: isNext ? AppTheme.secondaryColor : AppTheme.textMuted),
        title: Text(
          lang == 'ur' ? prayer.nameUrdu : prayer.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isNext ? AppTheme.secondaryColor : AppTheme.textDark,
            fontFamily: lang == 'ur' ? 'NotoNastaliqUrdu' : null,
          ),
        ),
        trailing: Text(
          prayer.time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNext ? AppTheme.secondaryColor : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
