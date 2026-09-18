import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/enums.dart';
import '../../models/meal_slot.dart';
import '../../models/time_slot.dart';
import '../../models/user_profile.dart';
import '../../providers/plan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'onboarding_scaffold.dart';

/// Multi-step intake questionnaire (FR-1.1-FR-1.6), designed to be
/// completable in under 5 minutes (NFR-7).
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _step = 0;
  static const _totalSteps = 6;
  bool _generating = false;

  // Step 0
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 1
  final _ageCtrl = TextEditingController(text: '25');
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '70');
  Gender _gender = Gender.other;
  FitnessGoal _goal = FitnessGoal.balancedAesthetic;
  ActivityLevel _activity = ActivityLevel.moderatelyActive;

  // Step 2
  EquipmentAccess _equipment = EquipmentAccess.homeBasic;
  final _injuriesCtrl = TextEditingController();

  // Step 3
  final List<TimeSlot> _workoutSlots = [];

  // Step 4
  final List<MealSlot> _mealSlots = [];

  // Step 5
  final Set<DietaryPreference> _diet = {DietaryPreference.none};
  final _dislikedCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _injuriesCtrl.dispose();
    _dislikedCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    setState(() => _generating = true);
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Athlete' : _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 25,
      gender: _gender,
      heightCm: double.tryParse(_heightCtrl.text) ?? 170,
      weightKg: double.tryParse(_weightCtrl.text) ?? 70,
      goal: _goal,
      activityLevel: _activity,
      injuriesOrConstraints: _splitCsv(_injuriesCtrl.text),
      workoutAvailability: _workoutSlots,
      mealAvailability: _mealSlots,
      dietaryPreferences: _diet.toList(),
      dislikedFoods: _splitCsv(_dislikedCtrl.text),
      equipmentAccess: _equipment,
      onboardingComplete: true,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    final planProvider = context.read<PlanProvider>();
    final settings = context.read<SettingsProvider>().settings;

    await userProvider.completeOnboarding(profile);
    await planProvider.generateAndSchedule(profile, settings);
    await NotificationService().requestPermissions();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  List<String> _splitCsv(String text) =>
      text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _welcomeStep();
      case 1:
        return _bodyGoalStep();
      case 2:
        return _equipmentStep();
      case 3:
        return _workoutAvailabilityStep();
      case 4:
        return _mealAvailabilityStep();
      default:
        return _dietStep();
    }
  }

  Widget _welcomeStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: "Let's build your plan",
      subtitle:
          'A few quick questions so we can tailor your workouts and meals to you.',
      onNext: _next,
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Your name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _bodyGoalStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: 'Your body & goal',
      subtitle: 'This shapes the aesthetic training style we build for you.',
      onNext: _next,
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Gender', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Gender.values
                .map(
                  (g) => ChoiceChip(
                    label: Text(g.name),
                    selected: _gender == g,
                    onSelected: (_) => setState(() => _gender = g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Target physique',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FitnessGoal.values
                .map(
                  (g) => ChoiceChip(
                    label: Text(g.label),
                    selected: _goal == g,
                    onSelected: (_) => setState(() => _goal = g),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Activity level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ActivityLevel.values
                .map(
                  (a) => ChoiceChip(
                    label: Text(a.name),
                    selected: _activity == a,
                    onSelected: (_) => setState(() => _activity = a),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _equipmentStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: 'Equipment & constraints',
      subtitle: 'So we only prescribe exercises you can actually perform.',
      onNext: _next,
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where do you train?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _SelectableTile(
                label: 'Full gym access',
                selected: _equipment == EquipmentAccess.fullGym,
                onTap: () =>
                    setState(() => _equipment = EquipmentAccess.fullGym),
              ),
              _SelectableTile(
                label: 'Home basics (dumbbells, bands)',
                selected: _equipment == EquipmentAccess.homeBasic,
                onTap: () =>
                    setState(() => _equipment = EquipmentAccess.homeBasic),
              ),
              _SelectableTile(
                label: 'Bodyweight only',
                selected: _equipment == EquipmentAccess.bodyweightOnly,
                onTap: () =>
                    setState(() => _equipment = EquipmentAccess.bodyweightOnly),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _injuriesCtrl,
            decoration: const InputDecoration(
              labelText: 'Injuries or medical constraints (comma separated)',
              hintText: 'e.g. lower back, left knee',
            ),
          ),
        ],
      ),
    );
  }

  Widget _workoutAvailabilityStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: 'When can you train?',
      subtitle:
          'Add every day/time window you have — we schedule workouts only inside these.',
      onNext: _workoutSlots.isEmpty ? null : _next,
      onBack: _back,
      nextLabel: _workoutSlots.isEmpty ? 'Add at least one slot' : 'Continue',
      child: _SlotListEditor(
        emptyLabel: 'No workout times added yet',
        entries: _workoutSlots
            .map(
              (s) =>
                  '${s.day.label} · ${s.startTimeLabel} · ${s.durationMinutes} min',
            )
            .toList(),
        onRemove: (i) => setState(() => _workoutSlots.removeAt(i)),
        onAdd: () async {
          final slot = await _pickTimeSlot(context, defaultDuration: 60);
          if (slot != null) setState(() => _workoutSlots.add(slot));
        },
      ),
    );
  }

  Widget _mealAvailabilityStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: 'When do you eat?',
      subtitle:
          'Add a window for each meal — breakfast, lunch, dinner, and any snacks.',
      onNext: _mealSlots.isEmpty ? null : _next,
      onBack: _back,
      nextLabel: _mealSlots.isEmpty ? 'Add at least one meal' : 'Continue',
      child: _SlotListEditor(
        emptyLabel: 'No meal times added yet',
        entries: _mealSlots
            .map(
              (m) =>
                  '${m.type.label} · ${m.slot.day.label} · ${m.slot.startTimeLabel}',
            )
            .toList(),
        onRemove: (i) => setState(() => _mealSlots.removeAt(i)),
        onAdd: () async {
          final mealSlot = await _pickMealSlot(context);
          if (mealSlot != null) setState(() => _mealSlots.add(mealSlot));
        },
      ),
    );
  }

  Widget _dietStep() {
    return OnboardingScaffold(
      step: _step,
      totalSteps: _totalSteps,
      title: 'Dietary preferences',
      subtitle: 'We will only suggest meals that fit.',
      onNext: _generating ? null : _next,
      onBack: _back,
      nextLabel: _generating ? 'Building your plan…' : 'Generate my plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DietaryPreference.values
                .map(
                  (d) => FilterChip(
                    label: Text(d.name),
                    selected: _diet.contains(d),
                    onSelected: (sel) => setState(() {
                      if (d == DietaryPreference.none) {
                        _diet
                          ..clear()
                          ..add(DietaryPreference.none);
                      } else {
                        _diet.remove(DietaryPreference.none);
                        sel ? _diet.add(d) : _diet.remove(d);
                        if (_diet.isEmpty) _diet.add(DietaryPreference.none);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _dislikedCtrl,
            decoration: const InputDecoration(
              labelText: 'Disliked foods (comma separated)',
              hintText: 'e.g. mushrooms, tofu',
            ),
          ),
          if (_generating) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<TimeSlot?> _pickTimeSlot(
    BuildContext context, {
    required int defaultDuration,
  }) async {
    WeekDay day = WeekDay.monday;
    TimeOfDay time = const TimeOfDay(hour: 18, minute: 0);
    int duration = defaultDuration;

    return showModalBottomSheet<TimeSlot>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add workout window',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WeekDay>(
                    initialValue: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: WeekDay.values
                        .map(
                          (d) =>
                              DropdownMenuItem(value: d, child: Text(d.label)),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => day = v!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start time'),
                    trailing: Text(time.format(ctx)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: time,
                      );
                      if (picked != null) setSheetState(() => time = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                    items: const [30, 45, 60, 75, 90]
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text('$m min')),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => duration = v!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        TimeSlot(
                          day: day,
                          startHour: time.hour,
                          startMinute: time.minute,
                          durationMinutes: duration,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<MealSlot?> _pickMealSlot(BuildContext context) async {
    MealType type = MealType.breakfast;
    WeekDay day = WeekDay.monday;
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);

    return showModalBottomSheet<MealSlot>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add meal window',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MealType>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Meal'),
                    items: MealType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.label)),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => type = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WeekDay>(
                    initialValue: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: WeekDay.values
                        .map(
                          (d) =>
                              DropdownMenuItem(value: d, child: Text(d.label)),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => day = v!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Time'),
                    trailing: Text(time.format(ctx)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: time,
                      );
                      if (picked != null) setSheetState(() => time = picked);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        MealSlot(
                          type: type,
                          slot: TimeSlot(
                            day: day,
                            startHour: time.hour,
                            startMinute: time.minute,
                            durationMinutes: 30,
                          ),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? scheme.primaryContainer : null,
      child: ListTile(
        title: Text(label),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? scheme.primary : scheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SlotListEditor extends StatelessWidget {
  final List<String> entries;
  final String emptyLabel;
  final void Function(int index) onRemove;
  final VoidCallback onAdd;

  const _SlotListEditor({
    required this.entries,
    required this.emptyLabel,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              emptyLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(
            entries.length,
            (i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(entries[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemove(i),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add time slot'),
        ),
      ],
    );
  }
}
