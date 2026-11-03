class ReadingProgress {
  int lastRead;
  Set<int> readAyat;
  ReadingProgress({this.lastRead = 0, Set<int>? readAyat}) : readAyat = readAyat ?? <int>{};

  Map<String, dynamic> toJson() => {'last': lastRead, 'read': readAyat.toList()..sort()};
  factory ReadingProgress.fromJson(Map<String, dynamic> j) => ReadingProgress(
        lastRead: (j['last'] as int?) ?? 0,
        readAyat: ((j['read'] as List?) ?? const []).map((e) => e as int).toSet(),
      );
}
