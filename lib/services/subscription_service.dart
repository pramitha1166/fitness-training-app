import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Wraps Apple StoreKit / Google Play Billing via the `in_app_purchase`
/// plugin (FR-6.1, FR-6.2).
///
/// IMPORTANT — store configuration this code cannot do for you:
/// the product id below must be created as an auto-renewing subscription
/// in App Store Connect and as a subscription in the Google Play Console
/// before `queryProductDetails` will return anything real. Until that is
/// done, `isStoreAvailable`/`queryProducts` will simply come back empty on
/// a real device, which is expected — it is a publisher-console step, not
/// a code change.
///
/// NFR-5 requires purchases to be validated server-side, not trusted from
/// the client alone. [onPurchaseVerified] is where that call belongs; today
/// it optimistically grants access after a successful platform purchase
/// event so the flow is testable end-to-end without a backend, but a
/// production build MUST post the receipt/purchase token to a server,
/// verify it against Apple/Google, and only then call
/// `completePurchase`/grant entitlement.
class SubscriptionService {
  static const String monthlySubscriptionProductId =
      'fitness_monthly_subscription';
  static const Set<String> productIds = {monthlySubscriptionProductId};
  static const int freeTrialDays = 7;

  InAppPurchase? _iapInstance;
  bool _platformUnavailable = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  void Function(PurchaseDetails details)? onPurchaseVerified;
  void Function(PurchaseDetails details)? onPurchaseFailed;
  void Function()? onPurchaseRestored;

  /// `InAppPurchase.instance` throws if no platform billing implementation
  /// registered itself (expected on Android/iOS, where the plugin does this
  /// automatically — but must never be allowed to crash the whole app on
  /// startup if it somehow doesn't).
  InAppPurchase? get _iap {
    if (_platformUnavailable) return null;
    try {
      return _iapInstance ??= InAppPurchase.instance;
    } catch (_) {
      _platformUnavailable = true;
      return null;
    }
  }

  Future<bool> get isStoreAvailable async {
    final iap = _iap;
    if (iap == null) return false;
    try {
      return await iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  void startListening() {
    final iap = _iap;
    if (iap == null) return;
    try {
      _subscription = iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (_) {},
      );
    } catch (_) {
      // Billing channel unavailable — subscription features stay gated
      // behind the free-trial path instead of crashing app startup.
    }
  }

  Future<List<ProductDetails>> queryProducts() async {
    final iap = _iap;
    if (iap == null) return [];
    try {
      if (!await iap.isAvailable()) return [];
      final response = await iap.queryProductDetails(productIds);
      return response.productDetails;
    } catch (_) {
      return [];
    }
  }

  Future<void> buySubscription(ProductDetails product) async {
    final iap = _iap;
    if (iap == null) throw StateError('Billing is unavailable on this device.');
    final param = PurchaseParam(productDetails: product);
    await iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    final iap = _iap;
    if (iap == null) throw StateError('Billing is unavailable on this device.');
    await iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          onPurchaseFailed?.call(purchase);
          break;
        case PurchaseStatus.canceled:
          onPurchaseFailed?.call(purchase);
          break;
        case PurchaseStatus.purchased:
          // TODO(backend): POST purchase.verificationData to the server for
          // receipt validation (NFR-5) before trusting it. Optimistically
          // verified here for local testability.
          onPurchaseVerified?.call(purchase);
          break;
        case PurchaseStatus.restored:
          onPurchaseVerified?.call(purchase);
          onPurchaseRestored?.call();
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap?.completePurchase(purchase);
      }
    }
  }

  /// The platform's native subscription management URL (FR-6.7). The UI
  /// layer opens this with `url_launcher`; kept as a plain URL here so this
  /// service has no direct UI dependency.
  String get manageSubscriptionsUrl {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/account/subscriptions';
    }
    return 'https://play.google.com/store/account/subscriptions';
  }

  void dispose() {
    _subscription?.cancel();
  }
}
