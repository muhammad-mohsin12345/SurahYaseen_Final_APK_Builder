import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../data/local/app_state.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/routes.dart';
import '../../shared/widgets/watch.dart';
import '../quran/ayat_card.dart';
import '../quran/display_options_sheet.dart';
import '../quran/quran_reader_screen.dart';

/// Translation-only reading with easy language switching.
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  bool _withArabic = false;

  int _langValue(bool u, bool e) => (u && e) ? 2 : (u ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final ayat = QuranRepository.I.ayat;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('translation')),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: () => showDisplayOptions(context),
          ),
        ],
      ),
      body: Watch(
        builder: (context) {
          final s = AppState.I.s;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                child: Column(
                  children: [
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(value: 0, label: Text(tr('urdu'))),
                        ButtonSegment(value: 1, label: Text(tr('english'))),
                        ButtonSegment(value: 2, label: Text(tr('both'))),
                      ],
                      selected: {_langValue(s.showUrdu, s.showEnglish)},
                      onSelectionChanged: (v) => AppState.I.update((x) {
                        x.showUrdu = v.first == 0 || v.first == 2;
                        x.showEnglish = v.first == 1 || v.first == 2;
                      }),
                    ),
                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(tr('arabicOnly')),
                      value: _withArabic,
                      onChanged: (v) => setState(() => _withArabic = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: ayat.length,
                  itemBuilder: (context, i) => AyatCard(
                    ayat: ayat[i],
                    mode: _withArabic ? 0 : 2,
                    onTap: () => go(context, QuranReaderScreen(initialAyat: ayat[i].number)),
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
