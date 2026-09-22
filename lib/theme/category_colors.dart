import 'package:flutter/material.dart';

import '../models/enums.dart';

/// A single accent color per muscle-group category, used for illustration
/// strokes, thumbnail tints, and tag pills so a given workout reads
/// consistently everywhere it appears.
Color colorForMuscleGroup(MuscleGroup group) {
  switch (group) {
    case MuscleGroup.legs:
    case MuscleGroup.glutes:
      return const Color(0xFFD9992C); // amber — "Muscle"
    case MuscleGroup.fullBody:
    case MuscleGroup.core:
      return const Color(0xFF2F8F4E); // green — "Cardio"
    case MuscleGroup.chest:
    case MuscleGroup.back:
    case MuscleGroup.shoulders:
    case MuscleGroup.arms:
      return const Color(0xFF6A56C9); // purple — "Strength"
  }
}
