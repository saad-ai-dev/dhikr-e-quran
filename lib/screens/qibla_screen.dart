import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class QiblaScreen extends StatefulWidget {
  final SettingsService settingsService;

  const QiblaScreen({super.key, required this.settingsService});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  bool _isLoading = true;
  String _error = '';

  String get _lang => widget.settingsService.language;
  String _s(String key) => S.get(key, _lang);

  // Kaaba coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _error = _lang == 'ur'
            ? 'لوکیشن سروس فعال کریں'
            : 'Enable location services';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _error = _lang == 'ur'
              ? 'مقام کی اجازت درکار ہے'
              : 'Location permission required';
        });
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium));

      final direction = _calculateBearing(
        position.latitude,
        position.longitude,
        _kaabaLat,
        _kaabaLon,
      );

      setState(() {
        _qiblaDirection = direction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error =
            _lang == 'ur' ? 'مقام حاصل نہیں ہو سکا' : 'Could not get location';
      });
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final y = sin(dLon) * cos(lat2Rad);
    final x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double deg) => deg * pi / 180;
  double _toDegrees(double rad) => rad * 180 / pi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_s('qibla'))),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off,
                          size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 12),
                      Text(_error,
                          style: const TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _calculateQibla, child: Text(_s('retry'))),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.secondaryColor.withOpacity(0.3),
                              width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Direction arrow
                            Transform.rotate(
                              angle: _toRadians(_qiblaDirection ?? 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.navigation_rounded,
                                      size: 60, color: AppTheme.secondaryColor),
                                  const SizedBox(height: 4),
                                  const Text('🕋',
                                      style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${_qiblaDirection?.toStringAsFixed(1)}°',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lang == 'ur' ? 'قبلہ کی سمت' : 'Qibla Direction',
                        style: AppTheme.urduSubtitle,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(_s('retry')),
                        onPressed: _calculateQibla,
                      ),
                    ],
                  ),
      ),
    );
  }
}
