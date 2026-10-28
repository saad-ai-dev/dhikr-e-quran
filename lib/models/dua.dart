class Dua {
  final int id;
  final String category;
  final String categoryEn;
  final String categoryUr;
  final String arabic;
  final String urdu;
  final String transliteration;
  final String reference;

  const Dua({
    required this.id,
    required this.category,
    required this.categoryEn,
    required this.categoryUr,
    required this.arabic,
    required this.urdu,
    required this.transliteration,
    required this.reference,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'],
      category: json['category'],
      categoryEn: json['category_en'],
      categoryUr: json['category_ur'],
      arabic: json['arabic'],
      urdu: json['urdu'],
      transliteration: json['transliteration'],
      reference: json['reference'],
    );
  }
}
