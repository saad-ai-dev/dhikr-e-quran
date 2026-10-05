import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

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
  late String _lang;

  @override
  void initState() {
    super.initState();
    _type = widget.settings.selectedType;
    _repeatVerse = widget.settings.repeatSingleVerse;
    _repeatName = widget.settings.repeatSingleName;
    _lang = widget.settings.language;
  }

  void _save() {
    widget.settings.selectedType = _type;
    widget.settings.repeatSingleVerse = _repeatVerse;
    widget.settings.repeatSingleName = _repeatName;
    widget.onChanged();
  }

  String _s(String key) => S.get(key, _lang);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_s('settingsTitle'), style: AppTheme.urduTitle.copyWith(fontSize: 18)),
          const Divider(),
          // Language toggle
          ListTile(
            leading: const Icon(Icons.language, color: AppTheme.secondaryColor, size: 20),
            title: Text(_s('language'), style: const TextStyle(fontSize: 14)),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(_s('english'), style: const TextStyle(fontSize: 12))),
                ButtonSegment(value: 'ur', label: Text(_s('urdu'), style: const TextStyle(fontSize: 12))),
              ],
              selected: {_lang},
              onSelectionChanged: (val) {
                setState(() => _lang = val.first);
                widget.settings.language = _lang;
                widget.onChanged();
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const Divider(),
          RadioListTile<ReminderType>(
            title: Text(_s('namesOfAllah'), style: const TextStyle(fontSize: 14)),
            value: ReminderType.allahNames,
            groupValue: _type,
            onChanged: (v) { setState(() => _type = v!); _save(); },
          ),
          RadioListTile<ReminderType>(
            title: Text(_s('quranSequence'), style: const TextStyle(fontSize: 14)),
            value: ReminderType.quranVerse,
            groupValue: _type,
            onChanged: (v) { setState(() => _type = v!); _save(); },
          ),
          const SizedBox(height: 8),
          if (_type == ReminderType.quranVerse)
            SwitchListTile(
              title: Text(_s('repeatVerse'), style: const TextStyle(fontSize: 14)),
              subtitle: Text(_s('repeatVerseDesc'), style: const TextStyle(fontSize: 12)),
              value: _repeatVerse,
              onChanged: (v) { setState(() => _repeatVerse = v); _save(); },
            ),
          if (_type == ReminderType.allahNames)
            SwitchListTile(
              title: Text(_s('repeatName'), style: const TextStyle(fontSize: 14)),
              subtitle: Text(_s('repeatNameDesc'), style: const TextStyle(fontSize: 12)),
              value: _repeatName,
              onChanged: (v) { setState(() => _repeatName = v); _save(); },
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            onPressed: () => Navigator.pop(context),
            child: Text(_s('savePreferences')),
          ),
        ],
      ),
    );
  }
}
