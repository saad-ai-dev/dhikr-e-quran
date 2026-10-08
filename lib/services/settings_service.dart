import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'reminder_service.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  int get reminderInterval =>
      _prefs.getInt(ReminderService.keyIntervalMinutes) ?? 15;
  set reminderInterval(int value) =>
      _prefs.setInt(ReminderService.keyIntervalMinutes, value);

  ReminderType get selectedType {
    int idx = _prefs.getInt(ReminderService.keyType) ?? 0;
    if (idx >= ReminderType.values.length) idx = 0;
    return ReminderType.values[idx];
  }

  set selectedType(ReminderType value) =>
      _prefs.setInt(ReminderService.keyType, value.index);

  int? get quietStartHour => _prefs.getInt(ReminderService.keyQuietStartHour);
  set quietStartHour(int? value) {
    if (value == null) {
      _prefs.remove(ReminderService.keyQuietStartHour);
    } else {
      _prefs.setInt(ReminderService.keyQuietStartHour, value);
    }
  }

  int? get quietEndHour => _prefs.getInt(ReminderService.keyQuietEndHour);
  set quietEndHour(int? value) {
    if (value == null) {
      _prefs.remove(ReminderService.keyQuietEndHour);
    } else {
      _prefs.setInt(ReminderService.keyQuietEndHour, value);
    }
  }

  int get specificNameIndex =>
      _prefs.getInt(ReminderService.keySpecificNameIndex) ?? 1;
  set specificNameIndex(int value) =>
      _prefs.setInt(ReminderService.keySpecificNameIndex, value);

  int get specificVerseIndex =>
      _prefs.getInt(ReminderService.keySpecificVerseIndex) ?? 1;
  set specificVerseIndex(int value) =>
      _prefs.setInt(ReminderService.keySpecificVerseIndex, value);

  String get language => _prefs.getString('app_language') ?? 'en';
  set language(String value) => _prefs.setString('app_language', value);

  int get tasbeehCount => _prefs.getInt('tasbeeh_count') ?? 0;
  set tasbeehCount(int value) => _prefs.setInt('tasbeeh_count', value);

  static Future<void> requestAppPermissions() async {
    if (!Platform.isAndroid) return;
    await Permission.notification.request();
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}
