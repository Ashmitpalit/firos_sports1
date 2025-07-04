import 'package:flutter/material.dart';

class TheatreCurtain extends StatefulWidget {
  final Widget child;

  const TheatreCurtain({super.key, required this.child});

  @override
  _TheatreCurtainState createState() => _TheatreCurtainState();
}

class _TheatreCurtainState extends State<TheatreCurtain> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Only draw the curtain if the animation is not complete
            return _animation.value < 1.0
                ? CustomPaint(
                    size: Size.infinite,
                    painter: CurtainPainter(_animation.value),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class CurtainPainter extends CustomPainter {
  final double animationValue;

  CurtainPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final leftCurtainPaint = Paint()
      ..color = Colors.red.withOpacity(0.9 * (1 - animationValue))
      ..style = PaintingStyle.fill;
    final rightCurtainPaint = Paint()
      ..color = Colors.red.withOpacity(0.9 * (1 - animationValue))
      ..style = PaintingStyle.fill;
    final goldTrimPaint = Paint()
      ..color = Colors.amber.withOpacity(0.7 * (1 - animationValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final leftCurtainWidth = size.width / 2 * (1 - animationValue);
    final rightCurtainWidth = size.width / 2 * (1 - animationValue);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, leftCurtainWidth, size.height),
      leftCurtainPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - rightCurtainWidth, 0, rightCurtainWidth, size.height),
      rightCurtainPaint,
    );

    canvas.drawLine(
      Offset(leftCurtainWidth, 0),
      Offset(leftCurtainWidth, size.height),
      goldTrimPaint,
    );
    canvas.drawLine(
      Offset(size.width - rightCurtainWidth, 0),
      Offset(size.width - rightCurtainWidth, size.height),
      goldTrimPaint,
    );

    final foldPaint = Paint()
      ..color = Colors.red[900]!.withOpacity(0.5 * (1 - animationValue))
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final x = leftCurtainWidth * (i + 1) / 6;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, leftCurtainWidth / 12, size.height),
        foldPaint,
      );
      final rightX = size.width - rightCurtainWidth * (i + 1) / 6;
      canvas.drawRect(
        Rect.fromLTWH(rightX - rightCurtainWidth / 12, 0, rightCurtainWidth / 12, size.height),
        foldPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CurtainPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => false; // Prevent painter from blocking taps
}
