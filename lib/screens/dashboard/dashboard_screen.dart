import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/plan_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/stat_card.dart';
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'Hi ${user.name.isEmpty ? 'there' : user.name} 👋',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(today.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        if (!sub.hasFullAccess) _PaywallBanner(sub: sub),
        if (!sub.hasFullAccess) const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Workout adherence',
                value: '${(plan.weeklyWorkoutAdherence * 100).round()}%',
                icon: Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Meal adherence',
                value: '${(plan.weeklyMealAdherence * 100).round()}%',
                icon: Icons.restaurant,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text("Today's workouts", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (todaysWorkouts.isEmpty)
          const _EmptyRow(text: 'No workout scheduled today. Enjoy the rest!'),
        ...todaysWorkouts.map(
          (s) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(s.title),
              subtitle: Text(
                '${s.slot.startTimeLabel} · ${s.exercises.length} exercises',
              ),
              trailing: _StatusPill(status: s.status),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(sessionId: s.id),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text("Today's meals", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (todaysMeals.isEmpty)
          const _EmptyRow(text: 'No meals scheduled today.'),
        ...todaysMeals.map(
          (m) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.15),
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
