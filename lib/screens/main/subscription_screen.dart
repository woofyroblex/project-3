import 'package:flutter/material.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription_model.dart';
import '../../services/auth_service.dart';

class SubscriptionScreen extends StatelessWidget {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AuthService _authService = AuthService();

  SubscriptionScreen({Key? key}) : super(key: key);

  Future<void> _handleSubscribe(BuildContext context) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to subscribe')),
        );
        return;
      }

      final subscription =
          await _subscriptionService.getUserSubscription(userId);

      if (!subscription.isActive) {
        final success = await _subscriptionService.subscribeToPremium(userId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully subscribed to Premium!')),
          );
          // Refresh the screen to show updated subscription status
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SubscriptionScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to subscribe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Subscription')),
      body: userId == null
          ? Center(child: Text('Please login to view subscription details'))
          : FutureBuilder<SubscriptionModel>(
              future: _subscriptionService.getUserSubscription(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final subscription = snapshot.data!;
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Plan: ${subscription.plan.name}'),
                      Text(
                          'Status: ${subscription.isActive ? "Active" : "Inactive"}'),
                      Text('Remaining Uses: ${subscription.remainingUses}'),
                      if (!subscription.isActive)
                        ElevatedButton(
                          onPressed: () => _handleSubscribe(context),
                          child: Text('Subscribe to Premium'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
