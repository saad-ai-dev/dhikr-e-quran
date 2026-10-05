import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final AudioPlayer versePlayer = AudioPlayer();
  final AudioPlayer namePlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  StreamSubscription? _verseCompleteSubscription;
  StreamSubscription? _nameCompleteSubscription;

  Future<void> playVerseWithTranslation({
    required String? arabicAudioPath,
    required String? urduAudioPath,
  }) async {
    await stopAll();

    if (arabicAudioPath != null) {
      await versePlayer.play(DeviceFileSource(arabicAudioPath));

      if (urduAudioPath != null) {
        _verseCompleteSubscription = versePlayer.onPlayerComplete.listen((event) async {
          _verseCompleteSubscription?.cancel();
          await namePlayer.play(DeviceFileSource(urduAudioPath));
        });
      }
    } else if (urduAudioPath != null) {
      await namePlayer.play(DeviceFileSource(urduAudioPath));
    }
  }

  Future<void> playNameAudio({required int nameIndex}) async {
    await stopAll();
    await namePlayer.play(AssetSource('audio/names/name_${nameIndex}_ar.mp3'));
    _nameCompleteSubscription = namePlayer.onPlayerComplete.listen((event) async {
      _nameCompleteSubscription?.cancel();
      await namePlayer.play(AssetSource('audio/names/name_${nameIndex}_ur.mp3'));
    });
  }

  Future<void> speakText(String text, {String language = "ur-PK", double rate = 0.45}) async {
    if (Platform.isLinux) {
      String espeakLang = language.startsWith("ar") ? "ar" : "ur";
      int speed = (150 * rate).round();
      await Process.run('espeak-ng', ['-v', espeakLang, '-s', '$speed', text]);
    } else {
      try {
        await _flutterTts.setLanguage(language);
        await _flutterTts.setSpeechRate(rate);
        await _flutterTts.speak(text);
      } catch (e) {
        print("TTS not available: $e");
      }
    }
  }

  Future<void> stopAll() async {
    _verseCompleteSubscription?.cancel();
    _nameCompleteSubscription?.cancel();
    await versePlayer.stop();
    await namePlayer.stop();
    if (Platform.isLinux) {
      await Process.run('pkill', ['-f', 'espeak-ng']);
    } else {
      try { await _flutterTts.stop(); } catch (_) {}
    }
  }

  void dispose() {
    _verseCompleteSubscription?.cancel();
    _nameCompleteSubscription?.cancel();
    versePlayer.dispose();
    namePlayer.dispose();
  }
}
