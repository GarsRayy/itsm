import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';

/// Full-screen animated mesh gradient background.
///
/// Creates overlapping radial gradient orbs that slowly shift position,
/// providing the deep-navy backdrop that makes glassmorphism pop.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundLight,
          ),
        ),

        // Animated orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _MeshGradientPainter(
                animationValue: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content layer
        widget.child,
      ],
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = animationValue * 2 * math.pi;

    // Orange orb — top right, slow drift
    _drawOrb(
      canvas,
      center: Offset(
        w * 0.75 + math.cos(t * 0.7) * w * 0.08,
        h * 0.15 + math.sin(t * 0.5) * h * 0.05,
      ),
      radius: w * 0.45,
      color: AppColors.primaryOrange.withValues(alpha: 0.15),
    );

    // Blue orb — bottom left
    _drawOrb(
      canvas,
      center: Offset(
        w * 0.2 + math.sin(t * 0.6) * w * 0.06,
        h * 0.7 + math.cos(t * 0.4) * h * 0.04,
      ),
      radius: w * 0.5,
      color: AppColors.accentBlue.withValues(alpha: 0.1),
    );

    // Purple orb — center, subtle
    _drawOrb(
      canvas,
      center: Offset(
        w * 0.5 + math.cos(t * 0.3) * w * 0.1,
        h * 0.45 + math.sin(t * 0.8) * h * 0.06,
      ),
      radius: w * 0.35,
      color: AppColors.accentPurple.withValues(alpha: 0.1),
    );

    // Yellow orb — bottom right accent
    _drawOrb(
      canvas,
      center: Offset(
        w * 0.85 + math.sin(t * 0.9) * w * 0.05,
        h * 0.85 + math.cos(t * 0.6) * h * 0.03,
      ),
      radius: w * 0.3,
      color: AppColors.primaryYellow.withValues(alpha: 0.12),
    );
  }

  void _drawOrb(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_MeshGradientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
