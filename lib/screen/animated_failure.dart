import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFailure extends StatefulWidget {
  final String message;

  const AnimatedFailure({super.key, required this.message});

  @override
  _AnimatedFailureState createState() => _AnimatedFailureState();
}

class _AnimatedFailureState extends State<AnimatedFailure> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 300),
                painter: RainPainter(_controller.value),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Verification Failed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.redAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.redAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
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

class RainPainter extends CustomPainter {
  final double animationValue;

  RainPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (int i = 0; i < 10; i++) {
      final x = i * size.width / 10;
      final y = size.height * (animationValue + i / 10) % size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        paint,
      );
    }

    final facePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 - 20),
      20,
      facePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2 - 10, size.height / 2), radius: 5),
      3.14159,
      3.14159,
      false,
      facePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2 + 10, size.height / 2), radius: 5),
      3.14159,
      3.14159,
      false,
      facePaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 + 10),
      Offset(size.width / 2, size.height / 2 + 20),
      facePaint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}
