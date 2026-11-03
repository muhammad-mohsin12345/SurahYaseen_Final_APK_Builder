import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ayat.dart';
import '../../data/repositories/quran_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/routes.dart';
import '../quran/quran_reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _c = TextEditingController();
  List<Ayat> _results = const [];
  bool _searched = false;

  void _run(String q) {
    setState(() {
      _results = QuranRepository.I.search(q);
      _searched = q.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('search'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _c,
              onChanged: _run,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: tr('searchHint'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _c.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _c.clear();
                          _run('');
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
          Expanded(
            child: _searched && _results.isEmpty
                ? Center(child: Text(tr('noResults')))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final a = _results[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: IslamicCard(
                          onTap: () => go(context, QuranReaderScreen(initialAyat: a.number)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: AppColors.emerald,
                                    child: Text('${a.number}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      a.arabic,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(a.english, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                a.urdu,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontFamily: 'NotoNastaliqUrdu', fontSize: 13, height: 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
