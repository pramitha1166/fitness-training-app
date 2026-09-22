import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_theme.dart';

/// A small rounded category chip (Cardio / Muscle / Strength style) used on
/// workout cards and lists.
class TagPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const TagPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  /// Maps a muscle group to a category label + color, so every exercise/
  /// workout card gets a consistent, meaningful tag.
  factory TagPill.forMuscleGroup(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.legs:
      case MuscleGroup.glutes:
        return const TagPill(
          label: 'Muscle',
          background: AppTheme.tagAmberBg,
          foreground: AppTheme.tagAmberFg,
        );
      case MuscleGroup.fullBody:
      case MuscleGroup.core:
        return const TagPill(
          label: 'Cardio',
          background: AppTheme.tagGreenBg,
          foreground: AppTheme.tagGreenFg,
        );
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.shoulders:
      case MuscleGroup.arms:
        return const TagPill(
          label: 'Strength',
          background: AppTheme.tagPurpleBg,
          foreground: AppTheme.tagPurpleFg,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
