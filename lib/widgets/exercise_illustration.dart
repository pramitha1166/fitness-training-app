import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../models/pose_type.dart';

/// A small original vector illustration of a person performing an
/// exercise's movement archetype, with a looping pose animation — every
/// exercise gets its own moving "image" without relying on stock photos
/// or network assets (FR-2.3).
class ExerciseIllustration extends StatefulWidget {
  final PoseType poseType;
  final Color color;
  final double size;
  final bool animate;

  const ExerciseIllustration({
    super.key,
    required this.poseType,
    required this.color,
    this.size = 56,
    this.animate = true,
  });

  @override
  State<ExerciseIllustration> createState() => _ExerciseIllustrationState();
}

class _ExerciseIllustrationState extends State<ExerciseIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ExerciseIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
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
      builder: (context, _) {
        final t = widget.animate ? _controller.value : 0.0;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _FigurePainter(
              poseType: widget.poseType,
              t: t,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

/// Interpolated joint/limb angles for a single animation frame.
class _Pose {
  final double armAngle; // degrees, 0 = straight down, 180 = straight up
  final double elbowBend; // 0 = straight, 1 = fully folded
  final double legAngle; // degrees, hip splay from vertical
  final double kneeBend; // 0 = straight, 1 = fully folded
  final double torsoLean; // degrees, forward lean
  final double bob; // vertical bounce, -1..1

  const _Pose({
    required this.armAngle,
    required this.elbowBend,
    required this.legAngle,
    required this.kneeBend,
    required this.torsoLean,
    required this.bob,
  });

  static _Pose lerp(_Pose a, _Pose b, double s) => _Pose(
    armAngle: lerpDouble(a.armAngle, b.armAngle, s)!,
    elbowBend: lerpDouble(a.elbowBend, b.elbowBend, s)!,
    legAngle: lerpDouble(a.legAngle, b.legAngle, s)!,
    kneeBend: lerpDouble(a.kneeBend, b.kneeBend, s)!,
    torsoLean: lerpDouble(a.torsoLean, b.torsoLean, s)!,
    bob: lerpDouble(a.bob, b.bob, s)!,
  );
}

/// Two keyframes per movement archetype; the painter eases between them.
(_Pose, _Pose) _keyframesFor(PoseType type) {
  switch (type) {
    case PoseType.press:
      return (
        const _Pose(
          armAngle: 130,
          elbowBend: 0.85,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
        const _Pose(
          armAngle: 15,
          elbowBend: 0.15,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
      );
    case PoseType.pull:
      return (
        const _Pose(
          armAngle: 175,
          elbowBend: 0.1,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: -4,
          bob: 0,
        ),
        const _Pose(
          armAngle: 55,
          elbowBend: 0.75,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 4,
          bob: 0,
        ),
      );
    case PoseType.curl:
      return (
        const _Pose(
          armAngle: 165,
          elbowBend: 0.05,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
        const _Pose(
          armAngle: 165,
          elbowBend: 0.9,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
      );
    case PoseType.lateralRaise:
      return (
        const _Pose(
          armAngle: 168,
          elbowBend: 0.08,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
        const _Pose(
          armAngle: 92,
          elbowBend: 0.08,
          legAngle: 8,
          kneeBend: 0.1,
          torsoLean: 0,
          bob: 0,
        ),
      );
    case PoseType.dip:
      return (
        const _Pose(
          armAngle: 160,
          elbowBend: 0.15,
          legAngle: 6,
          kneeBend: 0.15,
          torsoLean: 2,
          bob: 0.15,
        ),
        const _Pose(
          armAngle: 160,
          elbowBend: 0.85,
          legAngle: 6,
          kneeBend: 0.4,
          torsoLean: 4,
          bob: -0.35,
        ),
      );
    case PoseType.squat:
      return (
        const _Pose(
          armAngle: 95,
          elbowBend: 0.25,
          legAngle: 14,
          kneeBend: 0.12,
          torsoLean: 4,
          bob: 0.2,
        ),
        const _Pose(
          armAngle: 95,
          elbowBend: 0.25,
          legAngle: 20,
          kneeBend: 0.78,
          torsoLean: 16,
          bob: -0.55,
        ),
      );
    case PoseType.lunge:
      return (
        const _Pose(
          armAngle: 150,
          elbowBend: 0.3,
          legAngle: 10,
          kneeBend: 0.15,
          torsoLean: 3,
          bob: 0.15,
        ),
        const _Pose(
          armAngle: 150,
          elbowBend: 0.3,
          legAngle: 30,
          kneeBend: 0.6,
          torsoLean: 8,
          bob: -0.4,
        ),
      );
    case PoseType.hinge:
      return (
        const _Pose(
          armAngle: 175,
          elbowBend: 0.05,
          legAngle: 8,
          kneeBend: 0.15,
          torsoLean: 6,
          bob: 0,
        ),
        const _Pose(
          armAngle: 175,
          elbowBend: 0.05,
          legAngle: 10,
          kneeBend: 0.25,
          torsoLean: 48,
          bob: -0.1,
        ),
      );
    case PoseType.core:
      return (
        const _Pose(
          armAngle: 120,
          elbowBend: 0.5,
          legAngle: 4,
          kneeBend: 0.05,
          torsoLean: 90,
          bob: 0.06,
        ),
        const _Pose(
          armAngle: 120,
          elbowBend: 0.5,
          legAngle: 4,
          kneeBend: 0.05,
          torsoLean: 90,
          bob: -0.06,
        ),
      );
    case PoseType.cardio:
      return (
        const _Pose(
          armAngle: 150,
          elbowBend: 0.35,
          legAngle: 10,
          kneeBend: 0.35,
          torsoLean: 2,
          bob: -0.4,
        ),
        const _Pose(
          armAngle: 20,
          elbowBend: 0.15,
          legAngle: 22,
          kneeBend: 0.55,
          torsoLean: 0,
          bob: 0.5,
        ),
      );
  }
}

class _FigurePainter extends CustomPainter {
  final PoseType poseType;
  final double t;
  final Color color;

  _FigurePainter({
    required this.poseType,
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final (a, b) = _keyframesFor(poseType);
    // Smooth 0->1->0 easing across the loop.
    final s = (math.sin(t * 2 * math.pi - math.pi / 2) + 1) / 2;
    final pose = _Pose.lerp(a, b, s);

    final unit = size.shortestSide;
    final stroke = unit * 0.085;
    final headRadius = unit * 0.12;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()..color = color;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + unit * 0.06 * pose.bob);

    final torsoLen = unit * 0.34;
    final limbLen = unit * 0.19;
    final torsoRad = pose.torsoLean * math.pi / 180;

    // Torso: from hip (origin-ish) up to neck, rotated by torsoLean.
    final hip = Offset.zero;
    final neck =
        hip + Offset(math.sin(torsoRad), -math.cos(torsoRad)) * torsoLen;
    canvas.drawLine(hip, neck, paint);

    // Head.
    final headCenter =
        neck +
        Offset(math.sin(torsoRad), -math.cos(torsoRad)) * (headRadius * 1.15);
    canvas.drawCircle(headCenter, headRadius, fillPaint);

    // Arms (drawn as one visible arm for a clean side-view pictogram).
    _drawLimb(
      canvas,
      paint,
      origin: neck,
      firstLen: limbLen,
      secondLen: limbLen * 0.95,
      firstAngleDeg: pose.armAngle,
      bend: pose.elbowBend,
      mirrored: false,
    );

    // Legs (two, slightly offset for a grounded stance).
    _drawLimb(
      canvas,
      paint,
      origin: hip,
      firstLen: limbLen * 1.05,
      secondLen: limbLen,
      firstAngleDeg: 180 - pose.legAngle,
      bend: pose.kneeBend,
      mirrored: true,
    );
    _drawLimb(
      canvas,
      paint,
      origin: hip,
      firstLen: limbLen * 1.05,
      secondLen: limbLen,
      firstAngleDeg: 180 + pose.legAngle,
      bend: pose.kneeBend * 0.6,
      mirrored: true,
    );

    canvas.restore();
  }

  /// Draws a two-segment limb (upper + lower) starting at [origin]. Angle 0
  /// points straight down the screen; positive rotates toward the front.
  void _drawLimb(
    Canvas canvas,
    Paint paint, {
    required Offset origin,
    required double firstLen,
    required double secondLen,
    required double firstAngleDeg,
    required double bend,
    required bool mirrored,
  }) {
    final firstRad = firstAngleDeg * math.pi / 180;
    final dir = mirrored ? -1.0 : 1.0;
    final joint =
        origin +
        Offset(math.sin(firstRad) * dir, math.cos(firstRad)) * firstLen;

    final secondAngleDeg = firstAngleDeg - (bend * 100 * dir);
    final secondRad = secondAngleDeg * math.pi / 180;
    final end =
        joint +
        Offset(math.sin(secondRad) * dir, math.cos(secondRad)) * secondLen;

    canvas.drawLine(origin, joint, paint);
    canvas.drawLine(joint, end, paint);
  }

  @override
  bool shouldRepaint(covariant _FigurePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.poseType != poseType ||
      oldDelegate.color != color;
}
