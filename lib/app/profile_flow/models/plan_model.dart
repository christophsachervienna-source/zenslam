class SubscriptionPlan {
  final String id;
  final String planName;
  final double price;
  final String subscriptionType;
  final String? badge;
  final num? savings;
  final String? productId;
  final String? priceId;
  final List<PurchaseSubscription> purchaseSubscriptions;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.price,
    required this.subscriptionType,
    this.badge,
    this.savings,
    this.productId,
    this.priceId,
    this.purchaseSubscriptions = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      planName: json['planName'],
      price: (json['price'] as num).toDouble(),
      subscriptionType: json['subscriptionType'],
      badge: json['badge'],
      savings: json['savings'],
      productId: json['productId'],
      priceId: json['priceId'],
      purchaseSubscriptions:
          (json['purchaseSubscriptions'] as List<dynamic>?)
              ?.map((e) => PurchaseSubscription.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PurchaseSubscription {
  final String id;
  final bool isActive;

  PurchaseSubscription({required this.id, required this.isActive});

  factory PurchaseSubscription.fromJson(Map<String, dynamic> json) {
    return PurchaseSubscription(
      id: json['id'],
      isActive: json['isActive'] ?? false,
    );
  }
}
