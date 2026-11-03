import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/text_utils.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';
import '../models/tasbeeh.dart';
import '../models/user_settings.dart';

/// Single place that holds and saves everything the user changes.
/// Everything is stored on the phone with SharedPreferences (no internet).
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState I = AppState._();

  SharedPreferences? _p;
  UserSettings s = UserSettings();
  List<Bookmark> bookmarks = [];
  ReadingProgress progress = ReadingProgress();
  TasbeehData tasbeeh = TasbeehData();
  String? audioPath;

  bool get urdu => s.urdu;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    s = _read('settings', (m) => UserSettings.fromJson(m)) ?? UserSettings();
    progress = _read('progress', (m) => ReadingProgress.fromJson(m)) ?? ReadingProgress();
    tasbeeh = _read('tasbeeh', (m) => TasbeehData.fromJson(m)) ?? TasbeehData();
    try {
      final raw = _p!.getString('bookmarks');
      if (raw != null) {
        bookmarks = (jsonDecode(raw) as List)
            .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      bookmarks = [];
    }
    final ap = _p!.getString('audioPath');
    if (ap != null && File(ap).existsSync()) audioPath = ap;
  }

  T? _read<T>(String key, T Function(Map<String, dynamic>) f) {
    try {
      final raw = _p?.getString(key);
      if (raw == null) return null;
      return f(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void _write(String key, Object value) {
    _p?.setString(key, jsonEncode(value));
  }

  // ---------------- settings ----------------
  void update(void Function(UserSettings s) change) {
    change(s);
    _write('settings', s.toJson());
    notifyListeners();
  }

  void resetSettings() {
    s = UserSettings();
    _write('settings', s.toJson());
    notifyListeners();
  }

  Future<void> resetUserData() async {
    bookmarks = [];
    progress = ReadingProgress();
    tasbeeh = TasbeehData();
    _write('bookmarks', <dynamic>[]);
    _write('progress', progress.toJson());
    _write('tasbeeh', tasbeeh.toJson());
    notifyListeners();
  }

  // ---------------- bookmarks ----------------
  bool isBookmarked(int n) => bookmarks.any((b) => b.ayat == n);

  /// Returns true if the ayat is now bookmarked. Never creates duplicates.
  bool toggleBookmark(int n) {
    final i = bookmarks.indexWhere((b) => b.ayat == n);
    final added = i < 0;
    if (added) {
      bookmarks.insert(0, Bookmark(n, DateTime.now()));
    } else {
      bookmarks.removeAt(i);
    }
    _write('bookmarks', bookmarks.map((b) => b.toJson()).toList());
    notifyListeners();
    return added;
  }

  // ---------------- reading progress ----------------
  void markRead(Iterable<int> ayat, int last) {
    final before = progress.readAyat.length;
    progress.readAyat.addAll(ayat.where((n) => n >= 1 && n <= kTotalAyat));
    final changed = before != progress.readAyat.length || progress.lastRead != last;
    progress.lastRead = last;
    if (changed) {
      _write('progress', progress.toJson());
      notifyListeners();
    }
  }

  void resetProgress() {
    progress = ReadingProgress();
    _write('progress', progress.toJson());
    notifyListeners();
  }

  double get progressFraction => progress.readAyat.length / kTotalAyat;

  // ---------------- tasbeeh ----------------
  Dhikr get currentDhikr => kDhikrList[tasbeeh.selected.clamp(0, kDhikrList.length - 1)];
  int get currentCount => tasbeeh.counts[currentDhikr.id] ?? 0;
  int get todayTotal => tasbeeh.daily[todayKey()] ?? 0;

  void selectDhikr(int i) {
    tasbeeh.selected = i;
    _write('tasbeeh', tasbeeh.toJson());
    notifyListeners();
  }

  void tap() {
    final id = currentDhikr.id;
    tasbeeh.counts[id] = (tasbeeh.counts[id] ?? 0) + 1;
    final k = todayKey();
    tasbeeh.daily[k] = (tasbeeh.daily[k] ?? 0) + 1;
    if (tasbeeh.daily.length > 60) {
      final keys = tasbeeh.daily.keys.toList()..sort();
      for (final old in keys.take(tasbeeh.daily.length - 60)) {
        tasbeeh.daily.remove(old);
      }
    }
    _write('tasbeeh', tasbeeh.toJson());
    notifyListeners();
  }

  void resetCurrentDhikr() {
    tasbeeh.counts[currentDhikr.id] = 0;
    _write('tasbeeh', tasbeeh.toJson());
    notifyListeners();
  }

  // ---------------- audio ----------------
  void setAudioPath(String? path) {
    audioPath = path;
    if (path == null) {
      _p?.remove('audioPath');
    } else {
      _p?.setString('audioPath', path);
    }
    notifyListeners();
  }
}
