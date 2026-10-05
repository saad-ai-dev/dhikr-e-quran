import 'package:flutter/material.dart';
import '../models/ayah.dart';
import '../theme/app_theme.dart';

class AyahCard extends StatelessWidget {
  final Ayah ayah;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.onTap,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(icon: Icons.copy_rounded, tooltip: 'نقل کریں', onPressed: onCopy),
                  const SizedBox(height: 4),
                  _ActionIcon(icon: Icons.share_rounded, tooltip: 'شیئر کریں', onPressed: onShare),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(ayah.arabicText, textAlign: TextAlign.right, style: AppTheme.arabicBody),
                    const SizedBox(height: 10),
                    Text(ayah.urduText, textAlign: TextAlign.right, style: AppTheme.urduBody),
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionIcon({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16, color: AppTheme.secondaryColor),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      padding: EdgeInsets.zero,
    );
  }
}
