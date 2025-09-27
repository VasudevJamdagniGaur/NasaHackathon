import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarField extends StatefulWidget {
  const StarField({Key? key}) : super(key: key);

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final int _starCount = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _generateStars();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        opacity: random.nextDouble() * 0.8 + 0.2,
        speed: random.nextDouble() * 0.5 + 0.1,
        isPink: random.nextDouble() > 0.8,
        twinklePhase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: StarFieldPainter(_stars, _controller.value),
          );
        },
      ),
    );
  }
}

class Star {
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;
  final bool isPink;
  final double twinklePhase;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.isPink,
    required this.twinklePhase,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarFieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 1.0,
        colors: [
          const Color(0xFF121212),
          const Color(0xFF0A0A0A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw stars
    for (final star in stars) {
      // Update star position
      star.y += star.speed * 0.001;
      if (star.y > 1.0) {
        star.y = 0.0;
        star.x = math.Random().nextDouble();
      }

      // Calculate twinkle effect
      final twinkleValue = math.sin(animationValue * 2 * math.pi + star.twinklePhase);
      final currentOpacity = star.opacity * (0.5 + 0.5 * twinkleValue);

      // Choose star color
      final starColor = star.isPink 
          ? const Color(0xFFE91E63).withOpacity(currentOpacity)
          : Colors.white.withOpacity(currentOpacity);

      final paint = Paint()
        ..color = starColor
        ..style = PaintingStyle.fill;

      // Draw star with glow effect for pink stars
      final starX = star.x * size.width;
      final starY = star.y * size.height;
      final starSize = star.size;

      if (star.isPink) {
        // Add glow effect for pink stars
        final glowPaint = Paint()
          ..color = const Color(0xFFE91E63).withOpacity(currentOpacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        
        canvas.drawCircle(
          Offset(starX, starY),
          starSize * 3,
          glowPaint,
        );
      }

      canvas.drawCircle(
        Offset(starX, starY),
        starSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
