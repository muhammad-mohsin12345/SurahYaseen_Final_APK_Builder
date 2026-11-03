import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/local/app_state.dart';
import 'data/repositories/quran_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.mohsin.surahyaseen.audio',
      androidNotificationChannelName: 'Surah Yaseen audio',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('Audio background init failed: $e');
  }
  try {
    await AppState.I.load();
    await QuranRepository.I.load();
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load Quran data:\n$e', textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
    return;
  }
  await NotificationService.I.init();
  runApp(const SurahYaseenApp());
}
