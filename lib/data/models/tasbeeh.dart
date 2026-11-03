class Dhikr {
  final String id;
  final String arabic;
  final String en;
  final String ur;
  final int target;
  const Dhikr(this.id, this.arabic, this.en, this.ur, this.target);
}

/// Tasbeeh phrases are kept completely separate from the Quran text.
const List<Dhikr> kDhikrList = [
  Dhikr('subhanallah', 'سُبْحَانَ ٱللَّهِ', 'SubhanAllah', 'سبحان اللہ', 33),
  Dhikr('alhamdulillah', 'ٱلْحَمْدُ لِلَّهِ', 'Alhamdulillah', 'الحمدللہ', 33),
  Dhikr('allahuakbar', 'ٱللَّهُ أَكْبَرُ', 'Allahu Akbar', 'اللہ اکبر', 34),
  Dhikr('lailaha', 'لَا إِلَٰهَ إِلَّا ٱللَّهُ', 'La ilaha illallah', 'لا الہ الا اللہ', 100),
  Dhikr('astaghfirullah', 'أَسْتَغْفِرُ ٱللَّهَ', 'Astaghfirullah', 'استغفراللہ', 100),
  Dhikr('durood', 'ٱللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ', 'Durood (Salawat)', 'درود شریف', 100),
];

class TasbeehData {
  int selected;
  Map<String, int> counts; // current round per dhikr
  Map<String, int> daily; // yyyy-MM-dd -> total taps
  TasbeehData({this.selected = 0, Map<String, int>? counts, Map<String, int>? daily})
      : counts = counts ?? {},
        daily = daily ?? {};

  Map<String, dynamic> toJson() => {'sel': selected, 'counts': counts, 'daily': daily};
  factory TasbeehData.fromJson(Map<String, dynamic> j) => TasbeehData(
        selected: (j['sel'] as int?) ?? 0,
        counts: ((j['counts'] as Map?) ?? {}).map((k, v) => MapEntry(k as String, v as int)),
        daily: ((j['daily'] as Map?) ?? {}).map((k, v) => MapEntry(k as String, v as int)),
      );
}
