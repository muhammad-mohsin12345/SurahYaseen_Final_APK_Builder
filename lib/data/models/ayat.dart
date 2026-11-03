class Ayat {
  final int number;
  final String arabic;
  final String urdu;
  final String english;
  const Ayat({
    required this.number,
    required this.arabic,
    required this.urdu,
    required this.english,
  });

  factory Ayat.fromJson(Map<String, dynamic> j) => Ayat(
        number: j['number'] as int,
        arabic: j['arabic'] as String,
        urdu: j['urdu'] as String,
        english: j['english'] as String,
      );

  String shareText() =>
      '${arabic}\n\n${urdu}\n\n${english}\n\n— Surah Yaseen (36:$number)';
}

/// Translation / source attribution shown in Settings.
class SourceInfo {
  final String arabic;
  final String urdu;
  final String english;
  final String licence;
  const SourceInfo({
    required this.arabic,
    required this.urdu,
    required this.english,
    required this.licence,
  });
  factory SourceInfo.fromJson(Map<String, dynamic> j) => SourceInfo(
        arabic: j['arabic_source'] as String,
        urdu: j['urdu_source'] as String,
        english: j['english_source'] as String,
        licence: j['licence_note'] as String,
      );
}
