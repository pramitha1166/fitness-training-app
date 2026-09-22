import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../models/workout_session.dart';
import '../../providers/plan_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/category_colors.dart';
import '../../widgets/exercise_thumbnail.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/tag_pill.dart';
import '../meal/meal_detail_screen.dart';
import '../paywall/paywall_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../workout/workout_detail_screen.dart';

/// Main app shell: Home / Progress / Settings (FR-4.5, section 4.1).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTab(),
      const ProgressScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: tabs),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final plan = context.watch<PlanProvider>();
    final sub = context.watch<SubscriptionProvider>();
    final today = WeekDayX.fromDateTimeWeekday(DateTime.now().weekday);

    final todaysWorkouts = plan.sessionsFor(today);
    final todaysMeals = plan.mealsFor(today)
      ..sort(
        (a, b) => a.slot.startMinutesOfDay.compareTo(b.slot.startMinutesOfDay),
      );
    final primaryWorkout = todaysWorkouts.isEmpty ? null : todaysWorkouts.first;

    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name
              .trim()
              .split(RegExp(r'\s+'))
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back 👋',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.name.isEmpty ? 'Athlete' : user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.mint,
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!sub.hasFullAccess) ...[
          _PaywallBanner(sub: sub),
          const SizedBox(height: 16),
        ],
        _ProgressCard(
          session: primaryWorkout,
          adherence: plan.weeklyWorkoutAdherence,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Meal adherence',
                value: '${(plan.weeklyMealAdherence * 100).round()}%',
                icon: Icons.restaurant,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Workouts today',
                value: '${todaysWorkouts.length}',
                icon: Icons.today_outlined,
                color: AppTheme.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Recommendation', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (todaysWorkouts.isEmpty)
          const _EmptyRow(text: 'No workout scheduled today. Enjoy the rest!'),
        ...todaysWorkouts.map((s) {
          final color = colorForMuscleGroup(s.focus);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(sessionId: s.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ExerciseThumbnail(
                      exercise: s.exercises.first.exercise,
                      color: color,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TagPill.forMuscleGroup(s.focus),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${s.estimatedDurationMinutes} min',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.format_list_bulleted,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${s.exercises.length} exercises',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Text("Today's meals", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (todaysMeals.isEmpty)
          const _EmptyRow(text: 'No meals scheduled today.'),
        ...todaysMeals.map(
          (m) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text(m.food.name),
              subtitle: Text('${m.type.label} · ${m.slot.startTimeLabel}'),
              trailing: _StatusPill(status: m.status),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealDetailScreen(mealId: m.id),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final WorkoutSession? session;
  final double adherence;

  const _ProgressCard({required this.session, required this.adherence});

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progress',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s != null) TagPill.forMuscleGroup(s.focus),
                    const SizedBox(height: 10),
                    Text(
                      s?.title ?? 'Rest day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (s != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${s.estimatedDurationMinutes} min',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${s.exercises.length} exercises',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Nothing scheduled — a great day to recover or log a check-in.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProgressRing(
                  progress: adherence,
                  size: 64,
                  trackColor: Colors.white38,
                  valueColor: AppTheme.ink,
                  textColor: AppTheme.ink,
                ),
              ),
            ],
          ),
          if (s != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.ink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(sessionId: s.id),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Continue the workout',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaywallBanner extends StatelessWidget {
  final SubscriptionProvider sub;
  const _PaywallBanner({required this.sub});

  @override
  Widget build(BuildContext context) {
    final isExpired = sub.status.tier == SubscriptionTier.expired;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.lock_open),
        title: Text(
          isExpired ? 'Your access has ended' : 'Unlock your full plan',
        ),
        subtitle: Text(
          isExpired
              ? 'Resubscribe to keep your personalized plans and reminders.'
              : 'Start your free trial to unlock full personalization & alerts.',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final LogStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case LogStatus.completed:
        color = Colors.green;
        label = 'Done';
        break;
      case LogStatus.skipped:
        color = Colors.orange;
        label = 'Skipped';
        break;
      case LogStatus.rescheduled:
        color = Colors.blueGrey;
        label = 'Moved';
        break;
      case LogStatus.pending:
        color = Colors.grey;
        label = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
