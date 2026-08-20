import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class NetworkGridBackground extends StatefulWidget {
  final Widget child;

  const NetworkGridBackground({super.key, required this.child});

  @override
  State<NetworkGridBackground> createState() => _NetworkGridBackgroundState();
}

class _NetworkGridBackgroundState extends State<NetworkGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NetworkGridPainter(_controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _NetworkGridPainter extends CustomPainter {
  final double animationValue;

  _NetworkGridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    const double step = 32.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Draw pulsating network nodes
    final Paint nodePaint = Paint()
      ..color = AppConstants.primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final Random random = Random(42);
    for (int i = 0; i < 12; i++) {
      final double nx = random.nextDouble() * size.width;
      final double ny = random.nextDouble() * size.height;
      final double pulse = sin((animationValue * 2 * pi) + (i * 0.5)) * 0.5 + 0.5;

      canvas.drawCircle(Offset(nx, ny), 2.0 + (pulse * 3.0), nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkGridPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
