import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/plan_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/category_colors.dart';
import '../../widgets/exercise_illustration.dart';
import '../../widgets/exercise_thumbnail.dart';

/// FR-2.3 (exercise name, muscle group, sets/reps/rest, animated
/// illustration), FR-2.6 (mark complete/skipped/rescheduled).
class WorkoutDetailScreen extends StatefulWidget {
  final String sessionId;
  const WorkoutDetailScreen({super.key, required this.sessionId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();
    final session = plan.workoutPlan?.sessions.firstWhere(
      (s) => s.id == widget.sessionId,
    );

    if (session == null) {
      return const Scaffold(body: Center(child: Text('Workout not found')));
    }

    final color = colorForMuscleGroup(session.focus);
    final current = session.exercises.firstWhere(
      (we) => !we.completed,
      orElse: () => session.exercises.first,
    );
    final estCalories = session.exercises.fold<int>(
      0,
      (sum, we) => sum + (we.sets * we.reps * 0.35).round(),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Center(
                    child: ExerciseIllustration(
                      poseType: current.exercise.poseType,
                      color: Colors.white,
                      size: 160,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        Text(
                          session.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -46,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Up next',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                current.exercise.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${current.sets} sets × ${current.reps} reps · ${current.restSeconds}s rest',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatChip(
                          icon: Icons.local_fire_department,
                          label: '$estCalories kcal',
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 78)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...session.exercises.map(
                  (we) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: CheckboxListTile(
                      value: we.completed,
                      onChanged: (v) =>
                          setState(() => we.completed = v ?? false),
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(we.exercise.name),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${we.sets} sets × ${we.reps} reps · ${we.restSeconds}s rest\n${we.exercise.description}',
                        ),
                      ),
                      isThreeLine: true,
                      secondary: ExerciseThumbnail(
                        exercise: we.exercise,
                        color: colorForMuscleGroup(we.exercise.muscleGroup),
                        size: 52,
                        animate: !we.completed,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await plan.setWorkoutStatus(session.id, LogStatus.skipped);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await plan.setWorkoutStatus(
                      session.id,
                      LogStatus.completed,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Mark complete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
