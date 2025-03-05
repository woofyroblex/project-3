//lib/models/dashboard_item_data.dart
import 'package:flutter/material.dart';

/// Represents a single dashboard item with a title, icon, and navigation route.
class DashboardItemData {
  /// The title of the dashboard item.
  final String title;

  /// The icon representing the dashboard item.
  final IconData icon;

  /// The route name associated with the dashboard item.
  final String route;

  /// Optional tap handler for the dashboard item.
  final VoidCallback? onTap;

  /// Creates a new instance of `DashboardItemData`.
  const DashboardItemData({
    required this.title,
    required this.icon,
    required this.route,
    this.onTap,
  });

  /// Creates a list of predefined dashboard items.
  static List<DashboardItemData> get defaultItems => [
        DashboardItemData(
          title: 'Report Lost Item',
          icon: Icons.report_gmailerrorred,
          route: '/reportLostItem',
        ),
        DashboardItemData(
          title: 'Report Found Item',
          icon: Icons.find_in_page,
          route: '/reportFoundItem',
        ),
        DashboardItemData(
          title: 'Search Items',
          icon: Icons.search,
          route: '/searchItems',
        ),
        DashboardItemData(
          title: 'My Reports',
          icon: Icons.list_alt,
          route: '/myReports',
        ),
        DashboardItemData(
          title: 'History',
          icon: Icons.history,
          route: '/history',
        ),
        DashboardItemData(
          title: 'Profile',
          icon: Icons.person,
          route: '/profile',
        ),
        DashboardItemData(
          title: 'Subscription',
          icon: Icons.subscriptions,
          route: '/subscription',
        ),
        DashboardItemData(
          title: 'Payments',
          icon: Icons.payment,
          route: '/payment',
        ),
      ];
}
