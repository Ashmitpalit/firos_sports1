import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSuccess extends StatefulWidget {
  final int age;

  const AnimatedSuccess({super.key, required this.age});

  @override
  _AnimatedSuccessState createState() => _AnimatedSuccessState();
}

class _AnimatedSuccessState extends State<AnimatedSuccess> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
                painter: SupernovaPainter(_controller.value),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Identity Verified!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.cyanAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Age: ${widget.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.cyanAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.black),
                          ),
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

class SupernovaPainter extends CustomPainter {
  final double animationValue;

  SupernovaPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0.5 * (1 - animationValue)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 150 * animationValue));
    canvas.drawCircle(center, 150 * animationValue, paint);

    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.8 * (1 - animationValue))
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final angle = 2 * math.pi * i / 20 + animationValue * 2 * math.pi;
      final radius = 50 * animationValue + i * 5;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3.0, particlePaint);
    }
  }

  @override
  bool shouldRepaint(SupernovaPainter oldDelegate) => true;
}
