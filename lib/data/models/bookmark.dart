class Bookmark {
  final int ayat;
  final DateTime savedAt;
  Bookmark(this.ayat, this.savedAt);

  Map<String, dynamic> toJson() => {'a': ayat, 't': savedAt.toIso8601String()};
  factory Bookmark.fromJson(Map<String, dynamic> j) =>
      Bookmark(j['a'] as int, DateTime.tryParse(j['t'] as String? ?? '') ?? DateTime.now());
}
