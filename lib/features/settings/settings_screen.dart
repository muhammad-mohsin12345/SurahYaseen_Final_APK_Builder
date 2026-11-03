import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/services/audio_controller.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/watch.dart';
import '../reminders/reminder_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${tr('reset')}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('ok'))),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: Watch(
        builder: (context) {
          final s = AppState.I.s;
          final src = QuranRepository.I.sources;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              IslamicCard(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(tr('dark')),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: s.dark,
                      onChanged: (v) => AppState.I.update((x) => x.dark = v),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(tr('language')),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('English')),
                          ButtonSegment(value: true, label: Text('اردو')),
                        ],
                        selected: {s.urdu},
                        onSelectionChanged: (v) => AppState.I.update((x) => x.urdu = v.first),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IslamicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tr('arabicSize')}: ${s.arabicSize.round()}'),
                    Slider(
                      min: 20,
                      max: 52,
                      divisions: 32,
                      value: s.arabicSize.clamp(20, 52).toDouble(),
                      onChanged: (v) => AppState.I.update((x) => x.arabicSize = v),
                    ),
                    Text('${tr('transSize')}: ${s.transSize.round()}'),
                    Slider(
                      min: 12,
                      max: 30,
                      divisions: 18,
                      value: s.transSize.clamp(12, 30).toDouble(),
                      onChanged: (v) => AppState.I.update((x) => x.transSize = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IslamicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('audioSettings'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(tr('speed')),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [0.75, 1.0, 1.25, 1.5, 2.0]
                          .map((v) => ChoiceChip(
                                label: Text('${v}x'),
                                selected: s.speed == v,
                                onSelected: (_) => AudioController.I.setSpeed(v),
                              ))
                          .toList(),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tr('repeatSurah')),
                      value: s.repeatSurah,
                      onChanged: AudioController.I.setRepeatSurah,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const IslamicCard(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ReminderTile(),
              ),
              const SizedBox(height: 12),
              IslamicCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_backup_restore_rounded),
                      title: Text(tr('resetPrefs')),
                      onTap: () async {
                        if (await _confirm(context)) {
                          AppState.I.resetSettings();
                          await NotificationService.I.cancel();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                      title: Text(tr('resetAll')),
                      onTap: () async {
                        if (await _confirm(context)) await AppState.I.resetUserData();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (src != null)
                IslamicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('sources'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text('Arabic: ${src.arabic}', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 6),
                      Text('Urdu: ${src.urdu}', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 6),
                      Text('English: ${src.english}', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 6),
                      Text(src.licence, style: const TextStyle(fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 10),
                      const Text(
                        'Fonts: Amiri Quran & Noto Nastaliq Urdu (SIL Open Font License).',
                        style: TextStyle(fontSize: 12.5, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
