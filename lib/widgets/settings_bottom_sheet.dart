import 'package:flutter/material.dart';
import '../services/settings_service.dart';
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
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = widget.settings.language;
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
          const SizedBox(height: 16),
          // Reminder settings link
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded, color: AppTheme.secondaryColor, size: 20),
            title: Text(_s('reminders'), style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              '${_s('reminderEvery')} ${widget.settings.reminderInterval} ${_s('minutes')}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reminder');
            },
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
