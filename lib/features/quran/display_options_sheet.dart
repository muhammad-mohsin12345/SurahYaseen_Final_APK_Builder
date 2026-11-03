import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../data/local/app_state.dart';
import '../../shared/widgets/watch.dart';

/// Bottom sheet to change reading mode and font sizes (changes apply live).
void showDisplayOptions(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => Watch(
      builder: (ctx) {
        final s = AppState.I.s;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr('display'), style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(tr('both'))),
                    ButtonSegment(value: 1, label: Text(tr('arabicOnly'))),
                    ButtonSegment(value: 2, label: Text(tr('transOnly'))),
                  ],
                  selected: {s.displayMode},
                  onSelectionChanged: (v) => AppState.I.update((x) => x.displayMode = v.first),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text(tr('urdu')),
                      selected: s.showUrdu,
                      onSelected: (v) => AppState.I.update((x) => x.showUrdu = v),
                    ),
                    FilterChip(
                      label: Text(tr('english')),
                      selected: s.showEnglish,
                      onSelected: (v) => AppState.I.update((x) => x.showEnglish = v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
        );
      },
    ),
  );
}
