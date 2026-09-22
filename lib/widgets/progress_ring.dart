import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular percentage ring, e.g. "72%" of a workout/week completed.
class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final Color trackColor;
  final Color valueColor;
  final Color textColor;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 72,
    this.trackColor = Colors.white24,
    this.valueColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0, 1),
          trackColor: trackColor,
          valueColor: valueColor,
        ),
        child: Center(
          child: Text(
            '${(progress.clamp(0, 1) * 100).round()}%',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.22,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color valueColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.11;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final value = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      value,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.valueColor != valueColor;
}
