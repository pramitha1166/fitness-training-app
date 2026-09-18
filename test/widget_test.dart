import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_training_app/app.dart';
import 'package:fitness_training_app/providers/plan_provider.dart';
import 'package:fitness_training_app/providers/progress_provider.dart';
import 'package:fitness_training_app/providers/settings_provider.dart';
import 'package:fitness_training_app/providers/subscription_provider.dart';
import 'package:fitness_training_app/providers/user_provider.dart';
import 'package:fitness_training_app/services/notification_service.dart';
import 'package:fitness_training_app/services/storage_service.dart';
import 'package:fitness_training_app/services/subscription_service.dart';

void main() {
  testWidgets('App boots to the splash/onboarding screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.create();
    final notificationService = NotificationService();
    final subscriptionService = SubscriptionService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<NotificationService>.value(value: notificationService),
          ChangeNotifierProvider(create: (_) => UserProvider(storageService)),
          ChangeNotifierProvider(
            create: (_) => SettingsProvider(storageService),
          ),
          ChangeNotifierProvider(
            create: (_) => PlanProvider(storageService, notificationService),
          ),
          ChangeNotifierProvider(
            create: (_) => ProgressProvider(storageService),
          ),
          ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(
              storageService,
              subscriptionService,
              notificationService,
            ),
          ),
        ],
        child: const FitnessTrainingApp(),
      ),
    );

    expect(find.text('FitSculpt'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
  });
}
