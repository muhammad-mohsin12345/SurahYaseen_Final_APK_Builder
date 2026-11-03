import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/islamic_pattern.dart';

class SurahInfoScreen extends StatelessWidget {
  const SurahInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ur = AppState.I.urdu;
    final rows = <List<String>>[
      [ur ? 'سورت نمبر' : 'Surah number', '36'],
      [ur ? 'نام' : 'Name', ur ? 'یٰسٓ' : 'Ya-Seen'],
      [ur ? 'نزول' : 'Revelation', ur ? 'مکی' : 'Makki (Makkah)'],
      [ur ? 'آیات کی تعداد' : 'Number of ayat', '83'],
      [ur ? 'پارہ' : 'Juz', ur ? '22 اور 23' : '22 & 23'],
      [ur ? 'رکوع' : 'Rukus', '5'],
    ];
    return Scaffold(
      appBar: AppBar(title: Text(ur ? 'سورت کا تعارف' : 'Surah Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 170,
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
                      Text('سورة يس',
                          style: TextStyle(fontFamily: 'AmiriQuran', fontSize: 52, color: AppColors.gold)),
                      Text('Surah Yaseen',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          IslamicCard(
            child: Column(
              children: [
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r[0]),
                        Text(r[1], style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          IslamicCard(
            child: Text(
              ur
                  ? 'سورۃ یٰسٓ قرآنِ مجید کی 36ویں سورت ہے اور عام طور پر اسے "قرآن کا دل" کہا جاتا ہے۔ اس میں توحید، رسالت اور آخرت جیسے بنیادی موضوعات بیان ہوئے ہیں۔'
                  : 'Surah Yaseen is the 36th chapter of the Quran and is commonly called the "Heart of the Quran". It speaks about tawheed (oneness of Allah), prophethood and the Hereafter.',
              style: TextStyle(height: ur ? 2.0 : 1.5, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
