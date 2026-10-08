import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class TasbeehScreen extends StatefulWidget {
  final SettingsService settingsService;

  const TasbeehScreen({super.key, required this.settingsService});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  late int _count;

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  void initState() {
    super.initState();
    _count = widget.settingsService.tasbeehCount;
  }

  void _increment() {
    setState(() => _count++);
    widget.settingsService.tasbeehCount = _count;

    if (_count % 100 == 0) {
      _vibrate(duration: 500);
    } else if (_count % 33 == 0) {
      _vibrate(duration: 200);
    }
  }

  Future<void> _vibrate({int duration = 200}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_s('resetConfirm'), style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_s('no')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _count = 0);
              widget.settingsService.tasbeehCount = 0;
              Navigator.pop(ctx);
            },
            child: Text(_s('yes')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s('tasbeeh')),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Count display
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.cardGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$_count',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // Tap button
              GestureDetector(
                onTap: _increment,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _s('tap'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Reset button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label:
                      Text(_s('reset'), style: const TextStyle(fontSize: 13)),
                  style:
                      TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
