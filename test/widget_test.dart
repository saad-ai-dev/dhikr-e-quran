import 'package:flutter_test/flutter_test.dart';
import 'package:quran_urdu_app/models/ayah.dart';
import 'package:quran_urdu_app/models/allah_name.dart';
import 'package:quran_urdu_app/models/surah.dart';

void main() {
  test('Ayah.fromJson parses correctly', () {
    final json = {
      'ayah_number': 1,
      'arabic_text': 'بِسْمِ ٱللَّهِ',
      'phonetic_keywords': ['bismillah'],
      'urdu_text': 'شروع الله کا نام',
      'audio_primary': 'https://example.com/1.mp3',
      'audio_fallback': 'https://example.com/1f.mp3',
      'urdu_audio': 'https://example.com/1u.mp3',
    };
    final ayah = Ayah.fromJson(json);
    expect(ayah.ayahNumber, 1);
    expect(ayah.arabicText, 'بِسْمِ ٱللَّهِ');
    expect(ayah.phoneticKeywords, ['bismillah']);
  });

  test('AllahName.fromJson parses correctly', () {
    final json = {
      'id': 1,
      'arabic': 'الرَّحْمَـٰنُ',
      'transliteration': 'Ar-Rahmaan',
      'urdu_meaning': 'بے حد رحم کرنے والا',
    };
    final name = AllahName.fromJson(json);
    expect(name.id, 1);
    expect(name.transliteration, 'Ar-Rahmaan');
  });

  test('Surah.fromJson parses with ayahs', () {
    final json = {
      'surah_number': 1,
      'name_arabic': 'الفاتحة',
      'name_urdu': 'سورۃ الفاتحہ',
      'total_ayahs': 1,
      'ayahs': [
        {
          'ayah_number': 1,
          'arabic_text': 'بِسْمِ ٱللَّهِ',
          'phonetic_keywords': ['bismillah'],
          'urdu_text': 'شروع الله کا نام',
          'audio_primary': 'https://example.com/1.mp3',
          'audio_fallback': 'https://example.com/1f.mp3',
          'urdu_audio': 'https://example.com/1u.mp3',
        }
      ],
    };
    final surah = Surah.fromJson(json);
    expect(surah.surahNumber, 1);
    expect(surah.ayahs.length, 1);
    expect(surah.nameUrdu, 'سورۃ الفاتحہ');
  });
}
