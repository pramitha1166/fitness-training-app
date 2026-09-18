import 'enums.dart';

/// Locally-cached subscription state (FR-6.x). The authoritative state is
/// the server-validated receipt; see SubscriptionService for the
/// client/server split and where the app currently trusts local state as a
/// placeholder for a real backend.
class SubscriptionStatus {
  final SubscriptionTier tier;
  final DateTime? trialEndsAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final String? productId;
  final String? platformTransactionId;

  const SubscriptionStatus({
    required this.tier,
    this.trialEndsAt,
    this.expiresAt,
    this.autoRenew = false,
    this.productId,
    this.platformTransactionId,
  });

  factory SubscriptionStatus.free() =>
      const SubscriptionStatus(tier: SubscriptionTier.free);

  bool get hasFullAccess =>
      tier == SubscriptionTier.subscribed ||
      (tier == SubscriptionTier.trial &&
          trialEndsAt != null &&
          trialEndsAt!.isAfter(DateTime.now()));

  int get trialDaysRemaining {
    if (trialEndsAt == null) return 0;
    final diff = trialEndsAt!.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inDays + 1;
  }

  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    DateTime? trialEndsAt,
    DateTime? expiresAt,
    bool? autoRenew,
    String? productId,
    String? platformTransactionId,
  }) {
    return SubscriptionStatus(
      tier: tier ?? this.tier,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      productId: productId ?? this.productId,
      platformTransactionId:
          platformTransactionId ?? this.platformTransactionId,
    );
  }

  Map<String, dynamic> toJson() => {
    'tier': tier.name,
    'trialEndsAt': trialEndsAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'autoRenew': autoRenew,
    'productId': productId,
    'platformTransactionId': platformTransactionId,
  };

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        tier: SubscriptionTier.values.byName(json['tier'] as String),
        trialEndsAt: json['trialEndsAt'] != null
            ? DateTime.parse(json['trialEndsAt'] as String)
            : null,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        autoRenew: json['autoRenew'] as bool? ?? false,
        productId: json['productId'] as String?,
        platformTransactionId: json['platformTransactionId'] as String?,
      );
}
