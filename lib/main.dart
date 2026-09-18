import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/plan_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.create();
  final notificationService = NotificationService();
  await notificationService.init();
  final subscriptionService = SubscriptionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => UserProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => PlanProvider(storageService, notificationService),
        ),
        ChangeNotifierProvider(create: (_) => ProgressProvider(storageService)),
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
}
