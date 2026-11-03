import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_utils.dart';
import '../../data/local/app_state.dart';
import '../../data/models/ayat.dart';

/// One ayat with Arabic text, translations and action buttons.
/// [mode]: 0 = Arabic + translation, 1 = Arabic only, 2 = translation only.
class AyatCard extends StatelessWidget {
  final Ayat ayat;
  final bool highlight;
  final int mode;
  final VoidCallback? onTap;

  const AyatCard({
    super.key,
    required this.ayat,
    this.highlight = false,
    this.mode = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final st = AppState.I;
    final s = st.s;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bookmarked = st.isBookmarked(ayat.number);
    final showArabic = mode != 2;
    final showTrans = mode != 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.charcoalLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? AppColors.gold : AppColors.gold.withValues(alpha: 0.22),
          width: highlight ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald.withValues(alpha: dark ? 0.35 : 0.12),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      '${ayat.number}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Bookmark',
                    icon: Icon(
                      bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: bookmarked ? AppColors.gold : null,
                    ),
                    onPressed: () => st.toggleBookmark(ayat.number),
                  ),
                  IconButton(
                    tooltip: tr('copy'),
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: ayat.shareText()));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('copied')), duration: const Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: tr('share'),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    onPressed: () => Share.share(ayat.shareText()),
                  ),
                ],
              ),
              if (showArabic)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${ayat.arabic} \u06DD${toArabicDigits(ayat.number)}',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: s.arabicSize,
                      height: 2.1,
                    ),
                  ),
                ),
              if (showArabic && showTrans && (s.showUrdu || s.showEnglish))
                Divider(color: AppColors.gold.withValues(alpha: 0.35), height: 18),
              if (showTrans && s.showUrdu)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    ayat.urdu,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'NotoNastaliqUrdu',
                      fontSize: s.transSize,
                      height: 2.1,
                    ),
                  ),
                ),
              if (showTrans && s.showEnglish)
                Text(
                  ayat.english,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: s.transSize, height: 1.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
