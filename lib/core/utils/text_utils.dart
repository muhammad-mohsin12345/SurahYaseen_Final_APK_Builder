/// Converts 0-9 to Arabic-Indic digits (٠-٩).
String toArabicDigits(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

/// Converts Arabic-Indic / Urdu digits typed by the user to normal digits.
String normalizeDigits(String s) {
  const ar = '٠١٢٣٤٥٦٧٨٩';
  const ur = '۰۱۲۳۴۵۶۷۸۹';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i1 = ar.indexOf(ch);
    final i2 = ur.indexOf(ch);
    if (i1 >= 0) {
      b.write(i1);
    } else if (i2 >= 0) {
      b.write(i2);
    } else {
      b.write(ch);
    }
  }
  return b.toString();
}

final RegExp _marks =
    RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u08D3-\u08FF]');

/// Removes diacritics and unifies look-alike letters so searching works
/// for Arabic and Urdu typed with a normal keyboard.
String normalizeArabic(String s) {
  return s
      .replaceAll(_marks, '')
      .replaceAll(RegExp('[\u0622\u0623\u0625\u0671]'), '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u06CC', '\u064A')
      .replaceAll('\u06A9', '\u0643')
      .replaceAll('\u06C1', '\u0647')
      .replaceAll('\u06BE', '\u0647')
      .trim();
}

String todayKey() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

String fmtDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
}
