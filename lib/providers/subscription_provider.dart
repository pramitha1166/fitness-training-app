import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/subscription_service.dart';

/// Subscription/paywall gating (FR-6.1-FR-6.8). Wraps [SubscriptionService]
/// (the real StoreKit/Play Billing integration) and layers in a local free
/// trial so the paywall and feature-gating are testable without live store
/// products configured in App Store Connect / Play Console.
class SubscriptionProvider extends ChangeNotifier {
  final StorageService _storage;
  final SubscriptionService _service;
  final NotificationService _notifications;

  late SubscriptionStatus _status;
  SubscriptionStatus get status => _status;
  bool get hasFullAccess => _status.hasFullAccess;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool storeAvailable = false;
  String? lastError;

  SubscriptionProvider(this._storage, this._service, this._notifications) {
    _status = _storage.loadSubscriptionStatus();
    _expireIfNeeded();
    _service.onPurchaseVerified = _onPurchaseVerified;
    _service.onPurchaseFailed = _onPurchaseFailed;
    _service.onPurchaseRestored = _onPurchaseRestored;
    _service.startListening();
  }

  Future<void> init() async {
    try {
      storeAvailable = await _service.isStoreAvailable;
      if (storeAvailable) {
        _products = await _service.queryProducts();
      }
    } catch (e) {
      // Store not reachable in this environment (e.g. no store account
      // configured) — the local trial/paywall UI remains fully usable.
      storeAvailable = false;
      lastError = e.toString();
    }
    notifyListeners();
  }

  void _expireIfNeeded() {
    final now = DateTime.now();
    if (_status.tier == SubscriptionTier.trial &&
        _status.trialEndsAt != null &&
        _status.trialEndsAt!.isBefore(now)) {
      _status = _status.copyWith(tier: SubscriptionTier.expired);
      _persist();
    } else if (_status.tier == SubscriptionTier.subscribed &&
        _status.expiresAt != null &&
        _status.expiresAt!.isBefore(now) &&
        !_status.autoRenew) {
      _status = _status.copyWith(tier: SubscriptionTier.expired);
      _persist();
    }
  }

  Future<void> _persist() async {
    await _storage.saveSubscriptionStatus(_status);
    notifyListeners();
  }

  /// FR-6.3: configurable free trial before the first charge.
  Future<void> startFreeTrial() async {
    _status = SubscriptionStatus(
      tier: SubscriptionTier.trial,
      trialEndsAt: DateTime.now().add(
        Duration(days: SubscriptionService.freeTrialDays),
      ),
      autoRenew: true,
    );
    await _persist();
    await _notifications.showSubscriptionAlert(
      title: 'Free trial started',
      body:
          'Your ${SubscriptionService.freeTrialDays}-day free trial is active. Full plans and monitoring are unlocked.',
    );
  }

  Future<void> purchase() async {
    lastError = null;
    if (_products.isEmpty) {
      lastError =
          'Subscription product is not available from the store yet. Configure "${SubscriptionService.monthlySubscriptionProductId}" in App Store Connect / Play Console, or start the free trial to continue testing.';
      notifyListeners();
      return;
    }
    try {
      await _service.buySubscription(_products.first);
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> restore() async {
    lastError = null;
    try {
      await _service.restorePurchases();
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  void _onPurchaseVerified(PurchaseDetails details) {
    // FR-6.5: in production this fires only after server-side receipt
    // validation succeeds (see SubscriptionService docs).
    _status = SubscriptionStatus(
      tier: SubscriptionTier.subscribed,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      autoRenew: true,
      productId: details.productID,
      platformTransactionId: details.purchaseID,
    );
    _persist();
  }

  void _onPurchaseFailed(PurchaseDetails details) {
    lastError = details.error?.message ?? 'Purchase was not completed.';
    notifyListeners();
  }

  void _onPurchaseRestored() {
    _notifications.showSubscriptionAlert(
      title: 'Purchases restored',
      body: 'Your subscription has been restored.',
    );
  }

  /// FR-6.7
  String get manageSubscriptionsUrl => _service.manageSubscriptionsUrl;

  Future<void> cancelLocally() async {
    _status = _status.copyWith(autoRenew: false);
    await _persist();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
