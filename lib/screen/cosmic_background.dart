import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});

  @override
  _CosmicBackgroundState createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: CosmicPainter(_animation.value),
        );
      },
    );
  }
}

class CosmicPainter extends CustomPainter {
  final double animationValue;

  CosmicPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 50; i++) {
      final x = (i * 37 % size.width);
      final y = (i * 53 % size.height);
      final opacity = (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + i / 50)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        2.0 * (i % 3 + 1),
        starPaint..color = Colors.white.withOpacity(opacity),
      );
    }

    final cometPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final cometX = size.width * (animationValue % 1.0);
    final cometY = size.height * 0.3 + 50 * math.sin(animationValue * 2 * math.pi);
    canvas.drawCircle(Offset(cometX, cometY), 5.0, cometPaint);
    final tailPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(cometX, cometY),
      Offset(cometX - 50, cometY - 20),
      tailPaint,
    );
  }

  @override
  bool shouldRepaint(CosmicPainter oldDelegate) => true;
}
