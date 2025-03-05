import 'package:flutter/material.dart';
import 'package:lafa/models/dashboard_item_data.dart';
import 'package:provider/provider.dart';
import '../../components/dashboard/dashboard_card.dart';
import '../../components/dashboard/notification_icon.dart';
import '../../components/dashboard/dashboard_header.dart';
import 'package:lafa/config/routes/app_routes.dart';
import 'package:lafa/state/user_provider.dart';
import 'package:lafa/services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<DashboardItemData> _dashboardItems = [
    DashboardItemData(
      title: 'Report Lost Item',
      icon: Icons.report_gmailerrorred,
      route: AppRoutes.reportLostItem,
      onTap: null, // or remove this line
    ),
    DashboardItemData(
      title: 'Report Found Item',
      icon: Icons.find_in_page,
      route: AppRoutes.reportFoundItem,
      onTap: null, // or remove this line
    ),
    DashboardItemData(
      title: 'Search Items',
      icon: Icons.search,
      route: AppRoutes.searchItems,
      onTap: null, // or remove this line
    ),
    DashboardItemData(
      title: 'My Reports',
      icon: Icons.list_alt,
      route: AppRoutes.myReports,
    ),
    DashboardItemData(
      title: 'History',
      icon: Icons.history,
      route: AppRoutes.history,
    ),
    DashboardItemData(
      title: 'Profile',
      icon: Icons.person,
      route: AppRoutes.profile,
    ),
    DashboardItemData(
      title: 'Subscription',
      icon: Icons.subscriptions,
      route: AppRoutes.subscription,
    ),
    DashboardItemData(
      title: 'Payments',
      icon: Icons.payment,
      route: AppRoutes.payment,
    ),
  ];

  late NotificationService _notificationService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService =
        Provider.of<NotificationService>(context, listen: false);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      await _notificationService.fetchNotifications();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, NotificationService>(
      builder: (context, userProvider, notificationService, child) {
        final username = userProvider.username;
        final unreadCount = notificationService.unreadCount;

        return Scaffold(
          appBar: _buildAppBar(unreadCount),
          body: _buildBody(context, username),
        );
      },
    );
  }

  AppBar _buildAppBar(int unreadCount) {
    return AppBar(
      title: const Text(
        'LAFA Dashboard',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        NotificationIcon(unreadCount: unreadCount),
      ],
    );
  }

  Widget _buildBody(BuildContext context, String username) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<UserProvider>(context, listen: false)
              .refreshUserData();
          await _loadNotifications();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(username: username),
              const SizedBox(height: 20),
              _buildDashboardGrid(context),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecentActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            final item = _dashboardItems[index];
            return DashboardCard(
              title: item.title,
              icon: item.icon,
              onTap: () => Navigator.pushNamed(context, item.route),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    final activities = _notificationService.recentActivities;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: _getActivityIcon(activity.type),
          title: Text(activity.description),
          subtitle: Text(_formatDateTime(activity.timestamp)),
        );
      },
    );
  }

  Icon _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.report:
        return const Icon(Icons.report);
      case ActivityType.found:
        return const Icon(Icons.search);
      case ActivityType.match:
        return const Icon(Icons.check_circle);
      case ActivityType.payment:
        return const Icon(Icons.payment);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
