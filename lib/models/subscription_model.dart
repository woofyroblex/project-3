// subscription_model.dart
class SubscriptionPlan {
  final String name;
  final int price;
  final int serviceLimit;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.serviceLimit,
  });

  static const freePlan = SubscriptionPlan(
    name: 'Free Plan',
    price: 0,
    serviceLimit: 1,
  );

  static const premiumPlan = SubscriptionPlan(
    name: 'Premium Plan',
    price: 59,
    serviceLimit: -1, // Unlimited
  );
}

class SubscriptionModel {
  final String userId;
  final bool isActive;
  final DateTime? expiryDate;
  final int freeUsageCount;
  final String subscriptionType;
  final DateTime lastUpdated;
  final SubscriptionPlan plan;

  SubscriptionModel({
    required this.userId,
    required this.isActive,
    this.expiryDate,
    required this.freeUsageCount,
    required this.subscriptionType,
    required this.lastUpdated,
    required this.plan,
  });

  int get remainingUses => isActive ? -1 : freeUsageCount;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'isActive': isActive,
        'expiryDate': expiryDate?.toIso8601String(),
        'freeUsageCount': freeUsageCount,
        'subscriptionType': subscriptionType,
        'lastUpdated': lastUpdated.toIso8601String(),
        'plan': {
          'name': plan.name,
          'price': plan.price,
          'serviceLimit': plan.serviceLimit,
        },
      };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        userId: json['userId'],
        isActive: json['isActive'],
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        freeUsageCount: json['freeUsageCount'],
        subscriptionType: json['subscriptionType'],
        lastUpdated: DateTime.parse(json['lastUpdated']),
        plan: SubscriptionPlan(
          name: json['plan']['name'],
          price: json['plan']['price'],
          serviceLimit: json['plan']['serviceLimit'],
        ),
      );
}
