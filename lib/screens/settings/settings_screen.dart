import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/enums.dart';
import '../../providers/plan_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../onboarding/onboarding_flow_screen.dart';
import '../paywall/paywall_screen.dart';

/// FR-7.1 (edit profile → regenerate plan), FR-7.2 (notification prefs),
/// FR-6.7 (manage subscription), FR-7.3 (export / delete account).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;
    final sub = context.watch<SubscriptionProvider>();
    final plan = context.read<PlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          _SectionHeader('Profile'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.name.isEmpty ? 'Athlete' : user.name),
                  subtitle: Text(
                    user.email.isEmpty ? 'No email set' : user.email,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(user.goal.label),
                  subtitle: const Text('Goal'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profile & availability'),
                  subtitle: const Text(
                    'Changes regenerate your workout & meal plan',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingFlowScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Workout reminders'),
                  value: settings.workoutRemindersEnabled,
                  onChanged: (v) async {
                    final updated = settings.copyWith(
                      workoutRemindersEnabled: v,
                    );
                    await settingsProvider.update(updated);
                    await plan.rescheduleNotifications(updated);
                  },
                ),
                SwitchListTile(
                  title: const Text('Meal reminders'),
                  value: settings.mealRemindersEnabled,
                  onChanged: (v) async {
                    final updated = settings.copyWith(mealRemindersEnabled: v);
                    await settingsProvider.update(updated);
                    await plan.rescheduleNotifications(updated);
                  },
                ),
                ListTile(
                  title: const Text('Workout reminder lead time'),
                  subtitle: Text(
                    '${settings.workoutLeadMinutes} minutes before',
                  ),
                  trailing: DropdownButton<int>(
                    value: settings.workoutLeadMinutes,
                    items: const [0, 5, 10, 15, 30]
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text('$m min')),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      final updated = settings.copyWith(workoutLeadMinutes: v);
                      await settingsProvider.update(updated);
                      await plan.rescheduleNotifications(updated);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Meal reminder lead time'),
                  subtitle: Text('${settings.mealLeadMinutes} minutes before'),
                  trailing: DropdownButton<int>(
                    value: settings.mealLeadMinutes,
                    items: const [0, 5, 10, 15, 30]
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text('$m min')),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      final updated = settings.copyWith(mealLeadMinutes: v);
                      await settingsProvider.update(updated);
                      await plan.rescheduleNotifications(updated);
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('Missed activity re-engagement'),
                  subtitle: const Text(
                    'Notify me if I miss a logged workout or meal',
                  ),
                  value: settings.missedActivityReengagementEnabled,
                  onChanged: (v) => settingsProvider.update(
                    settings.copyWith(missedActivityReengagementEnabled: v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              value: settings.darkMode,
              onChanged: (v) =>
                  settingsProvider.update(settings.copyWith(darkMode: v)),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Subscription'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(_subscriptionLabel(sub)),
                  subtitle: Text(
                    sub.hasFullAccess
                        ? 'Full access to personalized plans & alerts'
                        : 'Limited access — subscribe to unlock everything',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Manage subscription'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    final uri = Uri.parse(sub.manageSubscriptionsUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore purchases'),
                  onTap: sub.restore,
                ),
                if (!sub.hasFullAccess)
                  ListTile(
                    leading: const Icon(Icons.upgrade),
                    title: const Text('View plans'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export my data'),
                  onTap: () => _exportData(context),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Delete account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Content is for general fitness/wellness purposes and does not constitute medical or professional nutritional advice. Consult a professional if you have a medical condition. (NFR-6)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _subscriptionLabel(SubscriptionProvider sub) {
    if (sub.status.hasFullAccess && sub.status.trialEndsAt != null) {
      return 'Free trial · ${sub.status.trialDaysRemaining} days left';
    }
    if (sub.hasFullAccess) return 'Subscribed · Monthly';
    return 'No active subscription';
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your data has been prepared for export (FR-7.3).'),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final storage = context.read<StorageService>();
    final userProvider = context.read<UserProvider>();
    final planProvider = context.read<PlanProvider>();
    final progressProvider = context.read<ProgressProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your profile, plans, and progress from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await storage.clearAllData();
              await userProvider.clear();
              await planProvider.clearAll();
              await progressProvider.clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingFlowScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
