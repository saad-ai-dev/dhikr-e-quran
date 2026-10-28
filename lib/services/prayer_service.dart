import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class PrayerTime {
  final String name;
  final String time;
  final String nameUrdu;

  const PrayerTime(
      {required this.name, required this.time, required this.nameUrdu});
}

class PrayerService {
  static const _prayerNames = {
    'Fajr': 'فجر',
    'Sunrise': 'طلوع آفتاب',
    'Dhuhr': 'ظہر',
    'Asr': 'عصر',
    'Maghrib': 'مغرب',
    'Isha': 'عشاء',
  };

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low));
  }

  static Future<List<PrayerTime>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 1,
  }) async {
    final today = DateTime.now();
    final url =
        'https://api.aladhan.com/v1/timings/${today.day}-${today.month}-${today.year}'
        '?latitude=$latitude&longitude=$longitude&method=$method';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['timings'];
        final prayers = <PrayerTime>[];
        for (final entry in _prayerNames.entries) {
          final time = data[entry.key] as String?;
          if (time != null) {
            prayers.add(PrayerTime(
              name: entry.key,
              time: time.split(' ').first,
              nameUrdu: entry.value,
            ));
          }
        }
        return prayers;
      }
    } catch (e) {
      print('Prayer time fetch error: $e');
    }
    return [];
  }

  static PrayerTime? getNextPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    for (final prayer in prayers) {
      final parts = prayer.time.split(':');
      if (parts.length == 2) {
        final prayerTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        if (prayerTime.isAfter(now)) return prayer;
      }
    }
    return prayers.isNotEmpty ? prayers.first : null;
  }
}
