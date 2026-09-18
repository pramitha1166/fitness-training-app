import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_provider.dart';
import '../../services/subscription_service.dart';
import '../../widgets/primary_button.dart';

/// FR-6.1-FR-6.4: monthly subscription paywall with free trial.
/// Apple/Google policy requires subscription length, price, and renewal
/// terms to be clearly stated before purchase (section 6) — shown below.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SubscriptionProvider>().init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final product = sub.products.isNotEmpty ? sub.products.first : null;
    final priceLabel = product?.price ?? '\$9.99 / month';

    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Icon(
            Icons.workspace_premium,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock your full aesthetic plan',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Personalized workouts, meal plans, monitoring and smart reminders — built around your schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Feature(text: 'Full personalized workout plan'),
                  _Feature(text: 'Full personalized meal plan with swaps'),
                  _Feature(text: 'Workout & meal time alerts'),
                  _Feature(text: 'Progress tracking, photos & charts'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly subscription — $priceLabel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${SubscriptionService.freeTrialDays}-day free trial, then $priceLabel, billed monthly. '
                    'Auto-renews unless cancelled at least 24 hours before the renewal date. '
                    'Manage or cancel anytime from your ${_storeName()} account settings.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (sub.lastError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                sub.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          PrimaryButton(
            label: sub.status.trialEndsAt == null
                ? 'Start free trial'
                : 'Subscribe now',
            loading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              if (sub.status.trialEndsAt == null) {
                await sub.startFreeTrial();
              } else {
                await sub.purchase();
              }
              setState(() => _loading = false);
              if (context.mounted && sub.hasFullAccess) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: sub.restore,
            child: const Text('Restore purchases'),
          ),
          const SizedBox(height: 8),
          Text(
            'By continuing you agree to auto-renewing billing through your app store account. Cancel anytime.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _storeName() {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? 'Apple'
        : 'Google Play';
  }
}

class _Feature extends StatelessWidget {
  final String text;
  const _Feature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
