import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/islamic_pattern.dart';
import '../../shared/widgets/press_button.dart';
import '../../shared/widgets/reveal.dart';
import '../../shared/widgets/routes.dart';
import '../../shared/widgets/watch.dart';
import '../audio/audio_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../info/surah_info_screen.dart';
import '../progress/progress_screen.dart';
import '../quran/quran_reader_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../tasbeeh/tasbeeh_screen.dart';
import '../translation/translation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Watch(
        builder: (context) {
          final st = AppState.I;
          final dark = Theme.of(context).brightness == Brightness.dark;
          final daily = QuranRepository.I.ayatOfTheDay();
          final last = st.progress.lastRead;
          final frac = st.progressFraction;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Reveal(child: _Header(frac: frac, readCount: st.progress.readAyat.length)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Reveal(
                  delay: const Duration(milliseconds: 120),
                  child: Row(
                    children: [
                      Expanded(
                        child: PressButton(
                          label: last > 0 ? '${tr('continue')} · $last' : tr('start'),
                          icon: Icons.menu_book_rounded,
                          onTap: () => go(context, QuranReaderScreen(initialAyat: last > 0 ? last : 1)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PressButton(
                          label: tr('play'),
                          icon: Icons.play_circle_outline_rounded,
                          filled: false,
                          onTap: () => go(context, const AudioScreen(autoPlay: true)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Reveal(
                  delay: const Duration(milliseconds: 240),
                  child: IslamicCard(
                    onTap: () => go(context, QuranReaderScreen(initialAyat: daily.number)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${tr('daily')} · ${daily.number}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: dark ? AppColors.gold : AppColors.emeraldDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          daily.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 26, height: 2.0),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          st.urdu ? daily.urdu : daily.english,
                          textDirection: st.urdu ? TextDirection.rtl : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: st.urdu ? 'NotoNastaliqUrdu' : null,
                            fontSize: 15,
                            height: st.urdu ? 2.0 : 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Reveal(
                  delay: const Duration(milliseconds: 360),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      _Tile(Icons.bookmark_rounded, tr('bookmarks'), () => go(context, const BookmarksScreen())),
                      _Tile(Icons.fingerprint_rounded, tr('tasbeeh'), () => go(context, const TasbeehScreen())),
                      _Tile(Icons.search_rounded, tr('search'), () => go(context, const SearchScreen())),
                      _Tile(Icons.translate_rounded, tr('translation'), () => go(context, const TranslationScreen())),
                      _Tile(Icons.insights_rounded, tr('progress'), () => go(context, const ProgressScreen())),
                      _Tile(Icons.info_outline_rounded, tr('info'), () => go(context, const SurahInfoScreen())),
                      _Tile(Icons.headphones_rounded, tr('audio'), () => go(context, const AudioScreen())),
                      _Tile(Icons.settings_rounded, tr('settings'), () => go(context, const SettingsScreen())),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double frac;
  final int readCount;
  const _Header({required this.frac, required this.readCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.emeraldDark, AppColors.emerald],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: PatternBackground(
        color: AppColors.gold.withValues(alpha: 0.16),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('salam'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 6),
                      const Text(
                        'سورة يس',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'AmiriQuran', color: AppColors.gold, fontSize: 40),
                      ),
                      Text(
                        tr('app'),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$kTotalAyat ${tr('ayat')} · Makki · 36',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: frac),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: v,
                            strokeWidth: 7,
                            backgroundColor: Colors.white24,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          '${(v * 100).round()}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IslamicCard(
      padding: const EdgeInsets.all(8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: dark ? AppColors.emeraldLight : AppColors.emerald),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
