import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/routes.dart';
import '../../shared/widgets/watch.dart';
import '../audio/audio_screen.dart';
import 'ayat_card.dart';
import 'display_options_sheet.dart';

/// Main reading screen: all 83 ayat in one scrolling page.
/// The visible ayat are saved automatically as "last read".
class QuranReaderScreen extends StatefulWidget {
  final int? initialAyat;
  const QuranReaderScreen({super.key, this.initialAyat});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final _ayat = QuranRepository.I.ayat;
  late final List<GlobalKey> _keys = List.generate(_ayat.length, (_) => GlobalKey());
  int _current = 1;

  @override
  void initState() {
    super.initState();
    _current = (widget.initialAyat ?? 1).clamp(1, kTotalAyat);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_current > 1) _jumpTo(_current, animate: false);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _updateVisible();
      });
    });
  }

  void _jumpTo(int n, {bool animate = true}) {
    final ctx = _keys[n - 1].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
    setState(() => _current = n);
  }

  /// Finds which ayat are on screen, highlights the first one and saves progress.
  void _updateVisible() {
    if (!mounted) return;
    final mq = MediaQuery.of(context);
    final top = mq.padding.top + kToolbarHeight;
    final bottomLimit = mq.size.height - 70;
    int? first;
    final seen = <int>[];
    for (var i = 0; i < _keys.length; i++) {
      final c = _keys[i].currentContext;
      if (c == null) continue;
      final rb = c.findRenderObject();
      if (rb is! RenderBox || !rb.attached) continue;
      final y = rb.localToGlobal(Offset.zero).dy;
      final b = y + rb.size.height;
      if (b > top + 8 && y < bottomLimit) {
        first ??= i + 1;
        seen.add(i + 1);
      }
      if (y > mq.size.height) break;
    }
    final f = first;
    if (f != null) {
      AppState.I.markRead(seen, f);
      if (f != _current) setState(() => _current = f);
    }
  }

  void _gotoDialog() async {
    final ctrl = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('goto')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '1 - $kTotalAyat'),
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
            child: Text(tr('ok')),
          ),
        ],
      ),
    );
    if (n != null && n >= 1 && n <= kTotalAyat) _jumpTo(n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('reading')),
        actions: [
          IconButton(
            tooltip: tr('audio'),
            icon: const Icon(Icons.headphones_rounded),
            onPressed: () => go(context, const AudioScreen()),
          ),
          IconButton(
            tooltip: tr('display'),
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: () => showDisplayOptions(context),
          ),
        ],
      ),
      body: Watch(
        builder: (context) {
          final mode = AppState.I.s.displayMode;
          return NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _updateVisible();
              return false;
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90, top: 4),
              child: Column(
                children: [
                  for (var i = 0; i < _ayat.length; i++)
                    KeyedSubtree(
                      key: _keys[i],
                      child: AyatCard(
                        ayat: _ayat[i],
                        mode: mode,
                        highlight: _current == i + 1,
                        onTap: () => setState(() => _current = i + 1),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 58,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          decoration: BoxDecoration(
            color: AppColors.emerald,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
                onPressed: _current > 1 ? () => _jumpTo(_current - 1) : null,
              ),
              TextButton(
                onPressed: _gotoDialog,
                child: Text(
                  '${tr('ayat')} $_current / $kTotalAyat',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.chevron_right_rounded, size: 30),
                onPressed: _current < kTotalAyat ? () => _jumpTo(_current + 1) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
