import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_model.dart';

class SubscriptionMiddleware {
  final SubscriptionService _subscriptionService = SubscriptionService();

  // Check if the user can access the service
  Future<bool> canAccessService(BuildContext context, String userId) async {
    try {
      // Fetch the current subscription status
      final SubscriptionModel subscription =
          await _subscriptionService.getUserSubscription(userId);

      // Check for active subscription or free usage
      if (subscription.isActive || subscription.freeUsageCount > 0) {
        if (!subscription.isActive) {
          // Deduct from free usage if no active subscription
          await _subscriptionService.useFreeService(userId);
        }
        return true;
      } else {
        // Prompt for subscription or payment
        _showSubscriptionPrompt(context);
        return false;
      }
    } catch (e) {
      debugPrint('Subscription check failed: $e');
      return false;
    }
  }

  // Show a dialog prompting for subscription or payment
  void _showSubscriptionPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Required'),
        content: Text(
            'You have used your free service. Subscribe to continue using premium services.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: Text('Subscribe Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
