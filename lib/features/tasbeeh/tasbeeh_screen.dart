import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_utils.dart';
import '../../data/local/app_state.dart';
import '../../data/models/tasbeeh.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/watch.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('tasbeeh')),
        actions: [
          IconButton(
            tooltip: tr('reset'),
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: AppState.I.resetCurrentDhikr,
          ),
        ],
      ),
      body: Watch(
        builder: (context) {
          final st = AppState.I;
          final d = st.currentDhikr;
          final count = st.currentCount;
          final urdu = st.urdu;
          final dark = Theme.of(context).brightness == Brightness.dark;
          final rounds = count ~/ d.target;
          final inRound = count % d.target;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kDhikrList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ChoiceChip(
                    label: Text(urdu ? kDhikrList[i].ur : kDhikrList[i].en),
                    selected: st.tasbeeh.selected == i,
                    onSelected: (_) => st.selectDhikr(i),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                d.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 36, height: 1.8),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    HapticFeedback.lightImpact();
                    st.tap();
                  },
                  child: AnimatedScale(
                    scale: _pressed ? 0.94 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: inRound / d.target),
                              duration: const Duration(milliseconds: 220),
                              builder: (context, v, _) => CircularProgressIndicator(
                                value: v,
                                strokeWidth: 9,
                                backgroundColor: AppColors.gold.withValues(alpha: 0.25),
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                          Container(
                            width: 208,
                            height: 208,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.emeraldDark, AppColors.emerald],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emerald.withValues(alpha: dark ? 0.4 : 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${tr('target')} ${d.target}',
                                  style: const TextStyle(color: AppColors.gold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _Stat(tr('today'), '${st.todayTotal}')),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat('×${d.target}', '$rounds')),
                ],
              ),
              const SizedBox(height: 16),
              IslamicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('last7'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _WeekBars(daily: st.tasbeeh.daily),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return IslamicCard(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  final Map<String, int> daily;
  const _WeekBars({required this.daily});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    String key(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final values = days.map((d) => daily[key(d)] ?? 0).toList();
    final maxV = values.fold<int>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${values[i]}', style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 18,
                    height: 4 + 64 * (values[i] / maxV),
                    decoration: BoxDecoration(
                      color: i == 6 ? AppColors.gold : AppColors.emerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${days[i].day}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
