import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/constants/strings.dart';
import '../../core/services/audio_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_utils.dart';
import '../../data/local/app_state.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/islamic_pattern.dart';

class AudioScreen extends StatefulWidget {
  final bool autoPlay;
  const AudioScreen({super.key, this.autoPlay = false});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with SingleTickerProviderStateMixin {
  final ctrl = AudioController.I;
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    _init();
  }

  StreamSubscription<PlayerState>? _sub;

  Future<void> _init() async {
    _sub = ctrl.player.playerStateStream.listen((st) {
      if (!mounted) return;
      if (st.playing) {
        if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
      } else {
        _pulse.stop();
      }
    });
    final ok = await ctrl.ensureLoaded();
    if (ok && widget.autoPlay && !ctrl.player.playing) {
      await ctrl.togglePlay();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _askUrl() async {
    final c = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('downloadAudio')),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(hintText: 'https://…/yaseen.mp3', labelText: tr('link')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(tr('download'))),
        ],
      ),
    );
    if (url != null && url.trim().isNotEmpty) await ctrl.downloadFromUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('audio'))),
      body: ListenableBuilder(
        listenable: Listenable.merge([ctrl, AppState.I]),
        builder: (context, _) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ctrl.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(ctrl.error!, style: const TextStyle(color: Colors.redAccent)),
                ),
              if (!ctrl.loaded) _buildImportCard(dark) else _buildPlayer(dark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImportCard(bool dark) {
    return IslamicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.headphones_rounded, size: 56, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(tr('noAudio'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(tr('audioHelp'), textAlign: TextAlign.center, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 18),
          if (ctrl.busy) ...[
            LinearProgressIndicator(value: ctrl.downloadProgress),
            const SizedBox(height: 8),
          ] else ...[
            FilledButton.icon(
              onPressed: ctrl.importFile,
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(tr('importAudio')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _askUrl,
              icon: const Icon(Icons.download_rounded),
              label: Text(tr('downloadAudio')),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayer(bool dark) {
    final p = ctrl.player;
    return Column(
      children: [
        StreamBuilder<PlayerState>(
          stream: p.playerStateStream,
          builder: (context, snap) {
            return AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Transform.scale(
                scale: 1 + 0.04 * _pulse.value,
                child: child,
              ),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.emeraldDark, AppColors.emerald],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: PatternBackground(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('يس',
                              style: TextStyle(
                                  fontFamily: 'AmiriQuran', fontSize: 72, color: AppColors.gold)),
                          Text('Surah Yaseen',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        StreamBuilder<Duration?>(
          stream: p.durationStream,
          builder: (context, dSnap) {
            final total = dSnap.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: p.positionStream,
              builder: (context, pSnap) {
                var pos = pSnap.data ?? Duration.zero;
                if (pos > total) pos = total;
                final max = total.inMilliseconds.toDouble();
                return Column(
                  children: [
                    Slider(
                      min: 0,
                      max: max <= 0 ? 1 : max,
                      value: max <= 0 ? 0.0 : pos.inMilliseconds.toDouble().clamp(0.0, max).toDouble(),
                      onChanged: (v) => p.seek(Duration(milliseconds: v.round())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(fmtDuration(pos)), Text(fmtDuration(total))],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        StreamBuilder<PlayerState>(
          stream: p.playerStateStream,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 38,
                  tooltip: '-10s',
                  icon: const Icon(Icons.replay_10_rounded),
                  onPressed: () => ctrl.skip(const Duration(seconds: -10)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: ctrl.togglePlay,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald,
                      border: Border.all(color: AppColors.gold, width: 2.5),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        key: ValueKey(playing),
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  iconSize: 38,
                  tooltip: '+10s',
                  icon: const Icon(Icons.forward_10_rounded),
                  onPressed: () => ctrl.skip(const Duration(seconds: 10)),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        IslamicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('speed'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((v) => ChoiceChip(
                          label: Text('${v}x'),
                          selected: AppState.I.s.speed == v,
                          onSelected: (_) => ctrl.setSpeed(v),
                        ))
                    .toList(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('repeatSurah')),
                value: AppState.I.s.repeatSurah,
                onChanged: ctrl.setRepeatSurah,
              ),
              const Divider(),
              Text(tr('abLoop'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                ctrl.abStart == null
                    ? '—'
                    : 'A ${fmtDuration(ctrl.abStart!)}  →  B ${ctrl.abEnd == null ? '—' : fmtDuration(ctrl.abEnd!)}',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: ctrl.setA, child: Text(tr('setA'))),
                  OutlinedButton(onPressed: ctrl.setB, child: Text(tr('setB'))),
                  TextButton(onPressed: ctrl.clearAB, child: Text(tr('clear'))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: ctrl.removeAudio,
          icon: const Icon(Icons.delete_outline_rounded),
          label: Text(tr('removeAudio')),
        ),
      ],
    );
  }
}
