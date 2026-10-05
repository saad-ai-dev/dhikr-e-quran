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

  int get reminderInterval => _prefs.getInt(ReminderService.keyIntervalMinutes) ?? 15;
  set reminderInterval(int value) => _prefs.setInt(ReminderService.keyIntervalMinutes, value);

  ReminderType get selectedType {
    int idx = _prefs.getInt(ReminderService.keyType) ?? 0;
    return ReminderType.values[idx];
  }
  set selectedType(ReminderType value) => _prefs.setInt(ReminderService.keyType, value.index);

  bool get repeatSingleVerse => _prefs.getBool(ReminderService.keyRepeatSingleVerse) ?? false;
  set repeatSingleVerse(bool value) => _prefs.setBool(ReminderService.keyRepeatSingleVerse, value);

  bool get repeatSingleName => _prefs.getBool(ReminderService.keyRepeatSingleName) ?? false;
  set repeatSingleName(bool value) => _prefs.setBool(ReminderService.keyRepeatSingleName, value);

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
