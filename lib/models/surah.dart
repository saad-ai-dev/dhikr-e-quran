import 'ayah.dart';

class Surah {
  final int surahNumber;
  final String nameArabic;
  final String nameUrdu;
  final int totalAyahs;
  final List<Ayah> ayahs;

  const Surah({
    required this.surahNumber,
    required this.nameArabic,
    required this.nameUrdu,
    required this.totalAyahs,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      surahNumber: json['surah_number'],
      nameArabic: json['name_arabic'],
      nameUrdu: json['name_urdu'],
      totalAyahs: json['total_ayahs'],
      ayahs: (json['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList(),
    );
  }
}
