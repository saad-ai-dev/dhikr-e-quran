class AllahName {
  final int id;
  final String arabic;
  final String transliteration;
  final String urduMeaning;

  const AllahName({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.urduMeaning,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      id: json['id'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      urduMeaning: json['urdu_meaning'],
    );
  }
}
