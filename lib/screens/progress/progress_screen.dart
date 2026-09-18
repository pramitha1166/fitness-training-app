import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/progress_log.dart';
import '../../providers/plan_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/primary_button.dart';

/// FR-4.1-FR-4.6: adherence, body metrics, progress photos, trend charts.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final plan = context.watch<PlanProvider>();
    final weightHistory = progress.weightHistory;
    final lowAdherence = progress.isAdherenceLow(
      plan.weeklyWorkoutAdherence,
      plan.weeklyMealAdherence,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Log check-in'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          if (lowAdherence)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your adherence has dropped this week. Consider adjusting your available time slots or plan intensity in Settings.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Weight trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                child: weightHistory.length < 2
                    ? const Center(
                        child: Text(
                          'Log at least two check-ins to see your trend.',
                        ),
                      )
                    : _WeightChart(logs: weightHistory),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Photo timeline', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (progress.photoTimeline.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No progress photos yet. Add one with your next check-in.',
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: progress.photoTimeline.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final log = progress.photoTimeline[i];
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(log.photoPath!),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.Md().format(log.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Check-in history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...progress.logs.reversed.map(
            (log) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(DateFormat.yMMMd().format(log.date)),
                subtitle: Text(
                  [
                    if (log.weightKg != null)
                      '${log.weightKg!.toStringAsFixed(1)} kg',
                    if (log.waistCm != null)
                      'waist ${log.waistCm!.toStringAsFixed(0)}cm',
                    if (log.notes != null && log.notes!.isNotEmpty) log.notes!,
                  ].join(' · '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => progress.removeLog(log.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    final progress = context.read<ProgressProvider>();
    final weightCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final hipsCtrl = TextEditingController();
    final armsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String? photoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New check-in',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightCtrl,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: waistCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Waist (cm)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: chestCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Chest (cm)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hipsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Hips (cm)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: armsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Arms (cm)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      photoPath == null ? 'Add progress photo' : 'Photo added',
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (img != null) {
                        setSheetState(() => photoPath = img.path);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Save check-in',
                    onPressed: () async {
                      await progress.addLog(
                        ProgressLog(
                          id: '',
                          date: DateTime.now(),
                          weightKg: double.tryParse(weightCtrl.text),
                          waistCm: double.tryParse(waistCtrl.text),
                          chestCm: double.tryParse(chestCtrl.text),
                          hipsCm: double.tryParse(hipsCtrl.text),
                          armsCm: double.tryParse(armsCtrl.text),
                          photoPath: photoPath,
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        ),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<ProgressLog> logs;
  const _WeightChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < logs.length; i++)
        FlSpot(i.toDouble(), logs[i].weightKg!),
    ];
    final color = Theme.of(context).colorScheme.primary;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
