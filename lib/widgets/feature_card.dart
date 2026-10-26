import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String titleUrdu;
  final String? subtitleUrdu;
  final VoidCallback onTap;
  final Color? accentColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.titleUrdu,
    this.subtitleUrdu,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.secondaryColor;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(titleUrdu,
                  style: AppTheme.urduBody
                      .copyWith(color: AppTheme.textDark, fontSize: 14),
                  textAlign: TextAlign.center),
              if (subtitleUrdu != null) ...[
                const SizedBox(height: 2),
                Text(subtitleUrdu!,
                    style: AppTheme.urduSubtitle.copyWith(fontSize: 11),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
