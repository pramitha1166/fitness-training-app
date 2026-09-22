import 'package:flutter/material.dart';

import '../models/exercise.dart';
import 'exercise_illustration.dart';

/// A rounded, tinted thumbnail card containing an [ExerciseIllustration] —
/// the vector-art stand-in for a workout photo used throughout the app.
class ExerciseThumbnail extends StatelessWidget {
  final Exercise exercise;
  final Color color;
  final double size;
  final bool animate;

  const ExerciseThumbnail({
    super.key,
    required this.exercise,
    required this.color,
    this.size = 64,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: ExerciseIllustration(
        poseType: exercise.poseType,
        color: color,
        size: size,
        animate: animate,
      ),
    );
  }
}
