class Ayah {
  final int ayahNumber;
  final String arabicText;
  final List<String> phoneticKeywords;
  final String urduText;
  final String audioPrimary;
  final String audioFallback;
  final String urduAudio;

  const Ayah({
    required this.ayahNumber,
    required this.arabicText,
    required this.phoneticKeywords,
    required this.urduText,
    required this.audioPrimary,
    required this.audioFallback,
    required this.urduAudio,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      ayahNumber: json['ayah_number'],
      arabicText: json['arabic_text'],
      phoneticKeywords: List<String>.from(json['phonetic_keywords']),
      urduText: json['urdu_text'],
      audioPrimary: json['audio_primary'],
      audioFallback: json['audio_fallback'],
      urduAudio: json['urdu_audio'],
    );
  }
}
