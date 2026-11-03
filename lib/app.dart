import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/local/app_state.dart';
import 'features/splash/splash_screen.dart';

class SurahYaseenApp extends StatelessWidget {
  const SurahYaseenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.I,
      builder: (context, _) {
        return MaterialApp(
          title: 'Surah Yaseen',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: AppState.I.s.dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => Directionality(
            textDirection: AppState.I.urdu ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
