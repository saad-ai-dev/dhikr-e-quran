import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/surah.dart';
import '../models/allah_name.dart';
import '../models/ayah.dart';

class AssetManager {
  List<SurahMeta> surahIndex = [];
  Surah? currentSurah;
  List<AllahName> allahNames = [];
  Map<int, String> arabicAudioPaths = {};
  Map<int, String> urduAudioPaths = {};

  bool get isReady => surahIndex.isNotEmpty && allahNames.isNotEmpty;

  Future<void> loadBaseData() async {
    if (isReady) return;

    final indexJson =
        await rootBundle.loadString('assets/json/surah_index.json');
    surahIndex = (jsonDecode(indexJson) as List)
        .map((s) => SurahMeta.fromJson(s))
        .toList();

    final namesJson =
        await rootBundle.loadString('assets/json/allah_names.json');
    allahNames = (jsonDecode(namesJson) as List)
        .map((n) => AllahName.fromJson(n))
        .toList();
  }

  Future<Surah> loadSurah(int surahNumber,
      {void Function(String)? onProgress}) async {
    final padded = surahNumber.toString().padLeft(3, '0');
    final json =
        await rootBundle.loadString('assets/json/surahs/surah_$padded.json');
    currentSurah = Surah.fromJson(jsonDecode(json));

    // Download audio for this surah
    arabicAudioPaths.clear();
    urduAudioPaths.clear();
    final appDocDir = await getApplicationDocumentsDirectory();

    for (final ayah in currentSurah!.ayahs) {
      final num = ayah.ayahNumber;
      final sNum = surahNumber;

      final arabicFile = File('${appDocDir.path}/surah_${sNum}_${num}_ar.mp3');
      if (!await arabicFile.exists()) {
        onProgress?.call('Downloading Ayah $num...');
        final ok = await _downloadFile(ayah.audioPrimary, arabicFile);
        if (!ok) await _downloadFile(ayah.audioFallback, arabicFile);
      }
      if (await arabicFile.exists()) {
        arabicAudioPaths[num] = arabicFile.path;
      }

      final urduFile = File('${appDocDir.path}/surah_${sNum}_${num}_ur.mp3');
      if (!await urduFile.exists()) {
        await _downloadFile(ayah.urduAudio, urduFile);
      }
      if (await urduFile.exists()) {
        urduAudioPaths[num] = urduFile.path;
      }
    }

    return currentSurah!;
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
