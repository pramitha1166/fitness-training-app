import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// Owns the user's profile — onboarding intake data and later edits
/// (FR-1.x, FR-7.1).
class UserProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  UserProfile _profile = UserProfile.empty();
  UserProfile get profile => _profile;
  bool get hasCompletedOnboarding => _profile.onboardingComplete;

  UserProvider(this._storage) {
    final saved = _storage.loadUserProfile();
    if (saved != null) _profile = saved;
  }

  Future<void> save(UserProfile profile) async {
    final withId = profile.id.isEmpty
        ? profile.copyWith(id: _uuid.v4())
        : profile;
    _profile = withId;
    await _storage.saveUserProfile(withId);
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await save(profile.copyWith(onboardingComplete: true));
  }

  Future<void> clear() async {
    _profile = UserProfile.empty();
    notifyListeners();
  }
}
