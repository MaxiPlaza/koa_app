import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class KovaMascot extends StatefulWidget {
  final KovaExpression expression;
  final double size;
  final VoidCallback? onTap;

  const KovaMascot({
    super.key,
    this.expression = KovaExpression.happy,
    this.size = 100,
    this.onTap,
  });

  @override
  State<KovaMascot> createState() => _KovaMascotState();
}

enum KovaExpression { happy, excited, thinking, celebrating, sleeping }

class _KovaMascotState extends State<KovaMascot> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _playAnimation();
  }

  void _playAnimation() {
    _controller.reset();
    _controller.forward();
  }

  String _getAnimationPath() {
    switch (widget.expression) {
      case KovaExpression.happy:
        return 'assets/animations/kova_happy.json';
      case KovaExpression.excited:
        return 'assets/animations/kova_excited.json';
      case KovaExpression.thinking:
        return 'assets/animations/kova_thinking.json';
      case KovaExpression.celebrating:
        return 'assets/animations/kova_celebrating.json';
      case KovaExpression.sleeping:
        return 'assets/animations/kova_sleeping.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _playAnimation();
      },
      child: Lottie.asset(
        _getAnimationPath(),
        controller: _controller,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
