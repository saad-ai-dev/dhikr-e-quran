import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/surah.dart';
import '../models/allah_name.dart';
import '../models/ayah.dart';

class AssetManager {
  Surah? surahData;
  List<AllahName> allahNames = [];
  Map<int, String> arabicAudioPaths = {};
  Map<int, String> urduAudioPaths = {};

  bool get isReady => surahData != null;

  Future<void> loadAllData({required void Function(String) onProgress}) async {
    String fatihaJson =
        await rootBundle.loadString('assets/json/surah_fatiha.json');
    surahData = Surah.fromJson(jsonDecode(fatihaJson));

    String namesJson =
        await rootBundle.loadString('assets/json/allah_names.json');
    allahNames = (jsonDecode(namesJson) as List)
        .map((n) => AllahName.fromJson(n))
        .toList();

    Directory appDocDir = await getApplicationDocumentsDirectory();

    for (Ayah ayah in surahData!.ayahs) {
      int num = ayah.ayahNumber;

      // Download Arabic audio
      File arabicFile = File('${appDocDir.path}/fatiha_001_$num.mp3');
      if (!await arabicFile.exists()) {
        onProgress('Downloading Ayah $num Arabic audio...');
        bool ok = await _downloadFile(ayah.audioPrimary, arabicFile);
        if (!ok) ok = await _downloadFile(ayah.audioFallback, arabicFile);
      }
      if (await arabicFile.exists()) arabicAudioPaths[num] = arabicFile.path;

      // Download Urdu audio
      File urduFile = File('${appDocDir.path}/fatiha_001_${num}_ur.mp3');
      if (!await urduFile.exists()) {
        onProgress('Downloading Ayah $num Urdu audio...');
        await _downloadFile(ayah.urduAudio, urduFile);
      }
      if (await urduFile.exists()) urduAudioPaths[num] = urduFile.path;
    }
  }

  Future<bool> _downloadFile(String url, File target) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        await target.writeAsBytes(response.bodyBytes);
        return true;
      }
    } catch (e) {
      print('Download error: $e');
    }
    return false;
  }
}
