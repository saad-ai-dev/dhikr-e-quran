import 'ayah.dart';

class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTranslation;
  final String revelationType;
  final int totalAyahs;

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTranslation,
    required this.revelationType,
    required this.totalAyahs,
  });

  factory SurahMeta.fromJson(Map<String, dynamic> json) {
    return SurahMeta(
      number: json['number'],
      nameArabic: json['name_arabic'],
      nameEnglish: json['name_english'],
      nameTranslation: json['name_translation'],
      revelationType: json['revelation_type'],
      totalAyahs: json['total_ayahs'],
    );
  }
}

class Surah {
  final int surahNumber;
  final String nameArabic;
  final String nameUrdu;
  final String nameEnglish;
  final String revelationType;
  final int totalAyahs;
  final List<Ayah> ayahs;

  const Surah({
    required this.surahNumber,
    required this.nameArabic,
    required this.nameUrdu,
    required this.nameEnglish,
    required this.revelationType,
    required this.totalAyahs,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      surahNumber: json['surah_number'],
      nameArabic: json['name_arabic'],
      nameUrdu: json['name_urdu'] ?? json['name_english'] ?? '',
      nameEnglish: json['name_english'] ?? '',
      revelationType: json['revelation_type'] ?? '',
      totalAyahs: json['total_ayahs'],
      ayahs: (json['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList(),
    );
  }
}
