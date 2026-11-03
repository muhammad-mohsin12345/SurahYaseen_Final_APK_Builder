import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/islamic_pattern.dart';
import '../../shared/widgets/routes.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: Curves.easeIn);
  late final Animation<double> _scale =
      Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeSlide(const HomeScreen()));
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emeraldDark, AppColors.emerald],
          ),
        ),
        child: PatternBackground(
          color: AppColors.gold.withValues(alpha: 0.18),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 3),
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Center(
                        child: Text(
                          'يس',
                          style: TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 64,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Surah Yaseen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'سورۃ یٰسٓ',
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        color: AppColors.gold,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
