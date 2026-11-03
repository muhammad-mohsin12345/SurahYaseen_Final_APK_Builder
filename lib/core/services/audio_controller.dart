import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/app_state.dart';

/// Wraps just_audio. Plays ONE full-surah recording that the user imports
/// or downloads. Works offline and in the background with notification controls.
class AudioController extends ChangeNotifier {
  AudioController._();
  static final AudioController I = AudioController._();

  final AudioPlayer player = AudioPlayer();
  bool loaded = false;
  String? error;
  double? downloadProgress; // 0..1 while downloading
  bool busy = false;

  Duration? abStart;
  Duration? abEnd;
  bool abLoop = false;
  bool _listening = false;

  bool get hasFile => AppState.I.audioPath != null;

  void _listen() {
    if (_listening) return;
    _listening = true;
    player.positionStream.listen((pos) {
      if (abLoop && abStart != null && abEnd != null && pos >= abEnd!) {
        player.seek(abStart);
      }
    });
  }

  Future<bool> ensureLoaded() async {
    if (loaded) return true;
    final path = AppState.I.audioPath;
    if (path == null || !File(path).existsSync()) return false;
    return _load(path);
  }

  Future<bool> _load(String path) async {
    try {
      error = null;
      _listen();
      await player.setAudioSource(AudioSource.uri(
        Uri.file(path),
        tag: const MediaItem(
          id: 'surah_yaseen',
          title: 'Surah Yaseen',
          artist: 'Recitation',
        ),
      ));
      await player.setSpeed(AppState.I.s.speed);
      await player.setLoopMode(AppState.I.s.repeatSurah ? LoopMode.one : LoopMode.off);
      loaded = true;
    } catch (e) {
      loaded = false;
      error = 'Could not play this file: $e';
    }
    notifyListeners();
    return loaded;
  }

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/yaseen_audio');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  Future<void> _clearOld() async {
    final old = AppState.I.audioPath;
    if (old != null) {
      try {
        await player.stop();
        final f = File(old);
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
    loaded = false;
    AppState.I.setAudioPath(null);
  }

  Future<void> importFile() async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.audio);
      final src = r?.files.single.path;
      if (src == null) return;
      busy = true;
      error = null;
      notifyListeners();
      await _clearOld();
      final ext = src.contains('.') ? src.split('.').last : 'mp3';
      final dest = '${(await _dir()).path}/yaseen_audio.$ext';
      await File(src).copy(dest);
      AppState.I.setAudioPath(dest);
      await _load(dest);
    } catch (e) {
      error = 'Import failed: $e';
    }
    busy = false;
    notifyListeners();
  }

  Future<void> downloadFromUrl(String url) async {
    HttpClient? client;
    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme) throw 'Link must start with http:// or https://';
      busy = true;
      error = null;
      downloadProgress = 0;
      notifyListeners();
      await _clearOld();
      client = HttpClient();
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode != 200) throw 'Server returned ${res.statusCode}';
      var ext = uri.path.contains('.') ? uri.path.split('.').last.toLowerCase() : 'mp3';
      if (ext.length > 4 || ext.isEmpty) ext = 'mp3';
      final dest = '${(await _dir()).path}/yaseen_audio.$ext';
      final sink = File(dest).openWrite();
      var got = 0;
      final total = res.contentLength;
      await for (final chunk in res) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) {
          downloadProgress = got / total;
          notifyListeners();
        }
      }
      await sink.close();
      AppState.I.setAudioPath(dest);
      await _load(dest);
    } catch (e) {
      error = 'Download failed: $e';
    } finally {
      client?.close();
      downloadProgress = null;
      busy = false;
      notifyListeners();
    }
  }

  Future<void> removeAudio() async {
    await _clearOld();
    abStart = null;
    abEnd = null;
    abLoop = false;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (!await ensureLoaded()) return;
    if (player.playing) {
      await player.pause();
    } else {
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      }
      player.play();
    }
  }

  Future<void> skip(Duration by) async {
    final dur = player.duration ?? Duration.zero;
    var t = player.position + by;
    if (t < Duration.zero) t = Duration.zero;
    if (dur > Duration.zero && t > dur) t = dur;
    await player.seek(t);
  }

  Future<void> setSpeed(double v) async {
    AppState.I.update((s) => s.speed = v);
    if (loaded) await player.setSpeed(v);
    notifyListeners();
  }

  Future<void> setRepeatSurah(bool v) async {
    AppState.I.update((s) => s.repeatSurah = v);
    if (loaded) await player.setLoopMode(v ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void setA() {
    abStart = player.position;
    if (abEnd != null && abEnd! <= abStart!) abEnd = null;
    abLoop = abStart != null && abEnd != null;
    notifyListeners();
  }

  void setB() {
    final p = player.position;
    if (abStart != null && p > abStart!) {
      abEnd = p;
      abLoop = true;
    }
    notifyListeners();
  }

  void clearAB() {
    abStart = null;
    abEnd = null;
    abLoop = false;
    notifyListeners();
  }
}
