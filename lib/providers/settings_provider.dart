import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// Notification and display preferences (FR-5.3, FR-7.2).
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  late AppSettings _settings;
  AppSettings get settings => _settings;

  SettingsProvider(this._storage) {
    _settings = _storage.loadSettings();
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    await _storage.saveSettings(settings);
    notifyListeners();
  }
}
