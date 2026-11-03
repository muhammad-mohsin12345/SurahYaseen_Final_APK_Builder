import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_state.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/routes.dart';
import '../../shared/widgets/watch.dart';
import '../quran/quran_reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('bookmarks'))),
      body: Watch(
        builder: (context) {
          final list = AppState.I.bookmarks;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.gold),
                    const SizedBox(height: 12),
                    Text(tr('noBookmarks'), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i];
              final a = QuranRepository.I.byNumber(b.ayat);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey('bm_${b.ayat}'),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => AppState.I.toggleBookmark(b.ayat),
                  child: IslamicCard(
                    onTap: () => go(context, QuranReaderScreen(initialAyat: b.ayat)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.emerald,
                          child: Text('${b.ayat}', style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            a.arabic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 20, height: 1.8),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove_rounded),
                          onPressed: () => AppState.I.toggleBookmark(b.ayat),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
