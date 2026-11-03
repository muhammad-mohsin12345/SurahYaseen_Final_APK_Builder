import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/app_constants.dart';
import '../../core/utils/text_utils.dart';
import '../models/ayat.dart';

class QuranRepository {
  QuranRepository._();
  static final QuranRepository I = QuranRepository._();

  List<Ayat> ayat = const [];
  SourceInfo? sources;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/surah_yaseen.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    ayat = (j['ayat'] as List)
        .map((e) => Ayat.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    sources = SourceInfo.fromJson(j['meta'] as Map<String, dynamic>);
    if (ayat.length != kTotalAyat) {
      throw StateError('Expected $kTotalAyat ayat but found ${ayat.length}');
    }
  }

  Ayat byNumber(int n) => ayat[(n.clamp(1, kTotalAyat)) - 1];

  /// Ayat of the day: changes every day, same all day.
  Ayat ayatOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return ayat[dayOfYear % kTotalAyat];
  }

  List<Ayat> search(String query) {
    final q0 = normalizeDigits(query.trim());
    if (q0.isEmpty) return const [];
    final asNumber = int.tryParse(q0);
    if (asNumber != null) {
      if (asNumber >= 1 && asNumber <= kTotalAyat) return [byNumber(asNumber)];
      return const [];
    }
    final qa = normalizeArabic(q0);
    final ql = q0.toLowerCase();
    return ayat.where((a) {
      return normalizeArabic(a.arabic).contains(qa) ||
          normalizeArabic(a.urdu).contains(qa) ||
          a.english.toLowerCase().contains(ql);
    }).toList();
  }
}
