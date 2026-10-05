import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../localization/app_strings.dart';

class HomeScreen extends StatefulWidget {
  final AssetManager assetManager;
  final AudioService audioService;
  final SettingsService settingsService;

  const HomeScreen({
    super.key,
    required this.assetManager,
    required this.audioService,
    required this.settingsService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s('appTitle')),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, label: _s('home'), isActive: true, onTap: () {}),
            _NavItem(icon: Icons.menu_book_rounded, label: _s('quran'), onTap: () => Navigator.pushNamed(context, '/quran')),
            _NavItem(icon: Icons.star_rounded, label: _s('names'), onTap: () => Navigator.pushNamed(context, '/names')),
            _NavItem(icon: Icons.tune_rounded, label: _s('settings'), onTap: () {
              SettingsBottomSheet.show(context, settings: widget.settingsService, onChanged: () => setState(() {}));
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                      style: TextStyle(fontSize: 20, fontFamily: 'ScheherazadeNew', color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'شروع الله کا نام لے کر جو بڑا مہربان نہایت رحم والا ہے',
                      style: TextStyle(fontSize: 12, fontFamily: 'NotoNastaliqUrdu', color: Colors.white.withOpacity(0.6)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    FeatureCard(
                      icon: Icons.menu_book_rounded,
                      titleUrdu: _s('quranPak'),
                      subtitleUrdu: _s('surahFatiha'),
                      onTap: () => Navigator.pushNamed(context, '/quran'),
                    ),
                    FeatureCard(
                      icon: Icons.star_rounded,
                      titleUrdu: _s('asmaAlHusna'),
                      subtitleUrdu: _s('names99'),
                      accentColor: AppTheme.accentGold,
                      onTap: () => Navigator.pushNamed(context, '/names'),
                    ),
                    FeatureCard(
                      icon: Icons.notifications_active_rounded,
                      titleUrdu: _s('yaadDehani'),
                      subtitleUrdu: '${_s('reminderEvery')} ${widget.settingsService.reminderInterval} ${_s('minutes')}',
                      accentColor: const Color(0xFFE67E22),
                      onTap: () => Navigator.pushNamed(context, '/quran'),
                    ),
                    FeatureCard(
                      icon: Icons.tune_rounded,
                      titleUrdu: _s('settings'),
                      accentColor: const Color(0xFF7C3AED),
                      onTap: () {
                        SettingsBottomSheet.show(context, settings: widget.settingsService, onChanged: () => setState(() {}));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accentGold : Colors.white54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontFamily: 'NotoNastaliqUrdu', color: color)),
        ],
      ),
    );
  }
}
