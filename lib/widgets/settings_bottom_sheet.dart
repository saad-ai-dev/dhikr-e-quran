import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

class SettingsBottomSheet {
  static void show(
    BuildContext context, {
    required SettingsService settings,
    required VoidCallback onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SettingsContent(settings: settings, onChanged: onChanged),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  final SettingsService settings;
  final VoidCallback onChanged;

  const _SettingsContent({required this.settings, required this.onChanged});

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  late ReminderType _type;
  late bool _repeatVerse;
  late bool _repeatName;

  @override
  void initState() {
    super.initState();
    _type = widget.settings.selectedType;
    _repeatVerse = widget.settings.repeatSingleVerse;
    _repeatName = widget.settings.repeatSingleName;
  }

  void _save() {
    widget.settings.selectedType = _type;
    widget.settings.repeatSingleVerse = _repeatVerse;
    widget.settings.repeatSingleName = _repeatName;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Reminder & Dhikr Settings", style: AppTheme.urduTitle.copyWith(fontSize: 20)),
          const Divider(),
          RadioListTile<ReminderType>(
            title: const Text("99 Names of Allah"),
            value: ReminderType.allahNames,
            groupValue: _type,
            onChanged: (v) { setState(() => _type = v!); _save(); },
          ),
          RadioListTile<ReminderType>(
            title: const Text("Complete Quran Sequence (6,236 Verses)"),
            value: ReminderType.quranVerse,
            groupValue: _type,
            onChanged: (v) { setState(() => _type = v!); _save(); },
          ),
          const SizedBox(height: 10),
          if (_type == ReminderType.quranVerse)
            SwitchListTile(
              title: const Text("Repeat One Verse"),
              subtitle: const Text("Locks and repeats the current verse"),
              value: _repeatVerse,
              onChanged: (v) { setState(() => _repeatVerse = v); _save(); },
            ),
          if (_type == ReminderType.allahNames)
            SwitchListTile(
              title: const Text("Repeat One Name"),
              subtitle: const Text("Locks and repeats one Name of Allah"),
              value: _repeatName,
              onChanged: (v) { setState(() => _repeatName = v); _save(); },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Save Preferences"),
          ),
        ],
      ),
    );
  }
}
