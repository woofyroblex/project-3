import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lafa/models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, SubscriptionModel> _subscriptionCache = {};
  late SubscriptionPlan currentPlan;
  int servicesUsed = 0;

  SubscriptionService() {
    initializePlan('Free Plan');
  }

  void initializePlan(String planName) {
    currentPlan = (planName == 'Premium Plan')
        ? SubscriptionPlan.premiumPlan
        : SubscriptionPlan.freePlan;
    servicesUsed = 0;
  }

  String getSubscriptionStatus() => currentPlan.name;
  bool isSubscribed() => currentPlan.name == 'Premium Plan';
  bool hasFreeUseLeft(String userId) => servicesUsed < 1;
  bool hasAccess() =>
      currentPlan.serviceLimit == -1 || servicesUsed < currentPlan.serviceLimit;

  Future<SubscriptionModel> getUserSubscription(String userId) async {
    try {
      if (_subscriptionCache.containsKey(userId)) {
        return _subscriptionCache[userId]!;
      }

      final docSnapshot =
          await _firestore.collection('subscriptions').doc(userId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final subscription = SubscriptionModel(
          userId: userId,
          isActive: data['isActive'] ?? false,
          freeUsageCount: data['freeUsageCount'] ?? 3,
          subscriptionType: data['subscriptionType'] ?? 'free',
          lastUpdated: DateTime.parse(data['lastUpdated']),
          plan: data['subscriptionType'] == 'premium'
              ? SubscriptionPlan.premiumPlan
              : SubscriptionPlan.freePlan,
        );
        _subscriptionCache[userId] = subscription;
        return subscription;
      }

      // Create new subscription for first-time users
      return _createNewSubscription(userId);
    } catch (e) {
      debugPrint('Error fetching subscription: $e');
      throw Exception('Failed to fetch subscription');
    }
  }

  Future<void> useFreeService(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription.freeUsageCount <= 0) {
        throw Exception('No free uses remaining');
      }

      final updatedSubscription = SubscriptionModel(
        userId: subscription.userId,
        isActive: subscription.isActive,
        expiryDate: subscription.expiryDate,
        freeUsageCount: subscription.freeUsageCount - 1,
        subscriptionType: subscription.subscriptionType,
        lastUpdated: DateTime.now(),
        plan: subscription.plan,
      );

      await _updateSubscriptionInDatabase(updatedSubscription);
      _subscriptionCache[userId] = updatedSubscription;
    } catch (e) {
      debugPrint('Error using free service: $e');
      throw Exception('Failed to use free service');
    }
  }

  Future<bool> subscribeToPremium(String userId) async {
    try {
      final updatedSubscription = SubscriptionModel(
        userId: userId,
        isActive: true,
        expiryDate: DateTime.now().add(Duration(days: 30)),
        freeUsageCount: 0,
        subscriptionType: 'premium',
        lastUpdated: DateTime.now(),
        plan: SubscriptionPlan.premiumPlan,
      );

      await _updateSubscriptionInDatabase(updatedSubscription);
      _subscriptionCache[userId] = updatedSubscription;
      return true;
    } catch (e) {
      debugPrint('Error subscribing to premium: $e');
      return false;
    }
  }

  Future<SubscriptionModel> _createNewSubscription(String userId) async {
    final subscription = SubscriptionModel(
      userId: userId,
      isActive: false,
      freeUsageCount: 3,
      subscriptionType: 'free',
      lastUpdated: DateTime.now(),
      plan: SubscriptionPlan.freePlan,
    );

    await _updateSubscriptionInDatabase(subscription);
    _subscriptionCache[userId] = subscription;
    return subscription;
  }

  Future<void> _updateSubscriptionInDatabase(
      SubscriptionModel subscription) async {
    await _firestore
        .collection('subscriptions')
        .doc(subscription.userId)
        .set(subscription.toJson());
  }

  Future<bool> hasActiveSubscription(String userId) async {
    final subscription = await getUserSubscription(userId);
    return subscription.isActive;
  }

  Future<int> getFreeUsageCount(String userId) async {
    final subscription = await getUserSubscription(userId);
    return subscription.freeUsageCount;
  }

  Future<bool> hasUsedFreeService(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      return subscription.freeUsageCount <= 0;
    } catch (e) {
      debugPrint('Error checking free service usage: $e');
      return true; // Assume used if error occurs
    }
  }

  Future<void> useService(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);

      if (!subscription.isActive && subscription.freeUsageCount <= 0) {
        throw Exception('No free uses remaining and no active subscription');
      }

      if (!subscription.isActive) {
        await useFreeService(userId);
      }

      await _updateLastUsed(userId);
    } catch (e) {
      debugPrint('Error using service: $e');
      throw Exception('Failed to use service: $e');
    }
  }

  Future<bool> chargeForService(String userId) async {
    try {
      // Implement actual payment processing here
      await Future.delayed(
          Duration(seconds: 2)); // Simulated payment processing

      final updatedSubscription = SubscriptionModel(
        userId: userId,
        isActive: true,
        expiryDate: DateTime.now().add(Duration(days: 30)),
        freeUsageCount: 0,
        subscriptionType: 'premium',
        lastUpdated: DateTime.now(),
        plan: SubscriptionPlan.premiumPlan,
      );

      await _updateSubscriptionInDatabase(updatedSubscription);
      _subscriptionCache[userId] = updatedSubscription;

      return true;
    } catch (e) {
      debugPrint('Error charging for service: $e');
      return false;
    }
  }

  Future<void> _updateLastUsed(String userId) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .update({'lastUsed': DateTime.now().toIso8601String()});
    } catch (e) {
      debugPrint('Error updating last used: $e');
    }
  }
}
