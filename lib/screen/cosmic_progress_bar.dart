import 'package:flutter/material.dart';

class CosmicProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final AnimationController controller;

  const CosmicProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            widthFactor: currentStep / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.blue],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.cyanAccent,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
