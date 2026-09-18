import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

class FitnessTrainingApp extends StatelessWidget {
  const FitnessTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = context.select<SettingsProvider, bool>(
      (s) => s.settings.darkMode,
    );

    return MaterialApp(
      title: 'FitSculpt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
