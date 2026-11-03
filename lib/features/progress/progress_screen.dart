import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/routes.dart';
import '../../shared/widgets/watch.dart';
import '../quran/quran_reader_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('progress')),
        actions: [
          IconButton(
            tooltip: tr('reset'),
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
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
              if (ok == true) AppState.I.resetProgress();
            },
          ),
        ],
      ),
      body: Watch(
        builder: (context) {
          final p = AppState.I.progress;
          final done = p.readAyat.length;
          final frac = AppState.I.progressFraction;
          final status = done >= kTotalAyat
              ? tr('completed')
              : (done == 0 ? tr('notStarted') : tr('inProgress'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              IslamicCard(
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: frac),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: v,
                                strokeWidth: 12,
                                backgroundColor: AppColors.gold.withValues(alpha: 0.25),
                                color: AppColors.emerald,
                              ),
                            ),
                            Text('${(v * 100).round()}%',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('$done / $kTotalAyat ${tr('ayat')} ${tr('read')}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(status, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                    if (p.lastRead > 0) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => go(context, QuranReaderScreen(initialAyat: p.lastRead)),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text('${tr('continue')} · ${p.lastRead}'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var n = 1; n <= kTotalAyat; n++)
                    GestureDetector(
                      onTap: () => go(context, QuranReaderScreen(initialAyat: n)),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: p.readAyat.contains(n)
                              ? AppColors.emerald
                              : AppColors.gold.withValues(alpha: 0.12),
                          border: Border.all(
                            color: p.lastRead == n ? AppColors.gold : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 12,
                            color: p.readAyat.contains(n) ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
