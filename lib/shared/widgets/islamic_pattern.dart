import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a tiled eight-pointed-star (Islamic geometric) pattern.
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double cell;
  const IslamicPatternPainter({required this.color, this.cell = 56});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final r = cell * 0.42;
    for (double y = cell / 2; y < size.height + cell; y += cell) {
      for (double x = cell / 2; x < size.width + cell; x += cell) {
        _star(canvas, Offset(x, y), r, p);
        canvas.drawCircle(Offset(x + cell / 2, y + cell / 2), r * 0.28, p);
      }
    }
  }

  void _star(Canvas c, Offset o, double r, Paint p) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final rad = i.isEven ? r : r * 0.62;
      final ang = math.pi * 2 * i / 16 - math.pi / 2;
      final pt = o + Offset(math.cos(ang) * rad, math.sin(ang) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter old) =>
      old.color != color || old.cell != cell;
}

/// Puts the pattern behind [child].
class PatternBackground extends StatelessWidget {
  final Widget child;
  final Color color;
  const PatternBackground({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: IslamicPatternPainter(color: color)),
          ),
        ),
        child,
      ],
    );
  }
}
