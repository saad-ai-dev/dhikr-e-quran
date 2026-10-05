import 'package:shared_preferences/shared_preferences.dart';

enum ReminderType { allahNames, quranVerse }

class ReminderService {
  static const String keyIntervalMinutes = 'reminder_interval';
  static const String keyType = 'reminder_type';
  static const String keyQuietStartHour = 'quiet_start_hour';
  static const String keyQuietEndHour = 'quiet_end_hour';
  static const String keyCurrentVerseIndex = 'current_verse_index';
  static const String keyCurrentNameIndex = 'current_name_index';
  static const String keyRepeatSingleVerse = 'repeat_single_verse';
  static const String keyRepeatSingleName = 'repeat_single_name';

  static Future<bool> isQuietHoursActive() async {
    final prefs = await SharedPreferences.getInstance();
    int? startHour = prefs.getInt(keyQuietStartHour);
    int? endHour = prefs.getInt(keyQuietEndHour);

    if (startHour == null || endHour == null) return false;

    int currentHour = DateTime.now().hour;
    if (startHour > endHour) {
      return currentHour >= startHour || currentHour < endHour;
    } else {
      return currentHour >= startHour && currentHour < endHour;
    }
  }

  static Future<int> getNextVerseIndex(int totalVersesInQuran) async {
    final prefs = await SharedPreferences.getInstance();
    bool isRepeatSingle = prefs.getBool(keyRepeatSingleVerse) ?? false;
    int currentIndex = prefs.getInt(keyCurrentVerseIndex) ?? 1;

    if (isRepeatSingle) {
      return currentIndex;
    }

    int nextIndex = currentIndex + 1;
    if (nextIndex > totalVersesInQuran) {
      nextIndex = 1;
    }

    await prefs.setInt(keyCurrentVerseIndex, nextIndex);
    return currentIndex;
  }

  static Future<int> getNextNameIndex() async {
    final prefs = await SharedPreferences.getInstance();
    bool isRepeatSingle = prefs.getBool(keyRepeatSingleName) ?? false;
    int currentIndex = prefs.getInt(keyCurrentNameIndex) ?? 1;

    if (isRepeatSingle) {
      return currentIndex;
    }

    int nextIndex = (currentIndex % 99) + 1;
    await prefs.setInt(keyCurrentNameIndex, nextIndex);
    return currentIndex;
  }
}
