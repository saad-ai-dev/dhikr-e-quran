class Ayah {
  final int ayahNumber;
  final int globalNumber;
  final String arabicText;
  final String urduText;
  final int juz;
  final int page;
  final String audioPrimary;
  final String audioFallback;
  final String urduAudio;

  const Ayah({
    required this.ayahNumber,
    required this.globalNumber,
    required this.arabicText,
    required this.urduText,
    required this.juz,
    required this.page,
    required this.audioPrimary,
    required this.audioFallback,
    required this.urduAudio,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      ayahNumber: json['ayah_number'],
      globalNumber: json['global_number'] ?? json['ayah_number'],
      arabicText: json['arabic_text'],
      urduText: json['urdu_text'],
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
      audioPrimary: json['audio_primary'],
      audioFallback: json['audio_fallback'],
      urduAudio: json['urdu_audio'],
    );
  }
}
