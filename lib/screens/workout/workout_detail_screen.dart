import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/plan_provider.dart';

/// FR-2.3 (exercise name, muscle group, sets/reps/rest, media placeholder),
/// FR-2.6 (mark complete/skipped/rescheduled).
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

    return Scaffold(
      appBar: AppBar(title: Text(session.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.calendar_today,
                      label: session.slot.day.label,
                      value: session.slot.startTimeLabel,
                    ),
                  ),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.timer_outlined,
                      label: 'Est. duration',
                      value: '${session.estimatedDurationMinutes} min',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Exercises', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...session.exercises.map(
            (we) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: CheckboxListTile(
                value: we.completed,
                onChanged: (v) => setState(() => we.completed = v ?? false),
                title: Text(we.exercise.name),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${we.exercise.muscleGroup.name} · ${we.sets} sets × ${we.reps} reps · ${we.restSeconds}s rest\n${we.exercise.description}',
                  ),
                ),
                isThreeLine: true,
                secondary: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}
