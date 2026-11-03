import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final raw = File('assets/data/surah_yaseen.json').readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final ayat = (json['ayat'] as List).cast<Map<String, dynamic>>();

  test('Surah Yaseen has exactly 83 ayat', () {
    expect(ayat.length, 83);
  });

  test('ayat numbers are 1..83 in order', () {
    for (var i = 0; i < ayat.length; i++) {
      expect(ayat[i]['number'], i + 1);
    }
  });

  test('every ayat has Arabic, Urdu and English text', () {
    for (final a in ayat) {
      expect((a['arabic'] as String).trim().isNotEmpty, true, reason: 'arabic ${a['number']}');
      expect((a['urdu'] as String).trim().isNotEmpty, true, reason: 'urdu ${a['number']}');
      expect((a['english'] as String).trim().isNotEmpty, true, reason: 'english ${a['number']}');
    }
  });

  test('source attribution exists', () {
    final meta = json['meta'] as Map<String, dynamic>;
    expect((meta['arabic_source'] as String).isNotEmpty, true);
    expect((meta['urdu_source'] as String).isNotEmpty, true);
    expect((meta['english_source'] as String).isNotEmpty, true);
  });
}
