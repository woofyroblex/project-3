import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/user_model.dart';
import '../../models/transaction_model.dart';
import '../../models/report_model.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/recent_users_list.dart';
import '../../widgets/transaction_list.dart';
import '../../widgets/reports_list.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _dashboardStats;
  List<UserModel> _recentUsers = [];
  List<TransactionModel> _recentTransactions = [];
  List<ReportModel> _recentReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      final stats = await _adminService.getDashboardStats();
      final users = await _adminService.getRecentUsers();
      final transactions = await _adminService.getRecentTransactions();
      final reports = await _adminService.getRecentReports();

      setState(() {
        _dashboardStats = stats;
        _recentUsers = users;
        _recentTransactions = transactions;
        _recentReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatistics(),
                    const SizedBox(height: 24),
                    _buildRecentUsers(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                    const SizedBox(height: 24),
                    _buildRecentReports(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatistics() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardCard(
          title: 'Total Users',
          value: _dashboardStats?['totalUsers']?.toString() ?? '0',
          icon: Icons.people,
        ),
        DashboardCard(
          title: 'Total Reports',
          value: _dashboardStats?['totalReports']?.toString() ?? '0',
          icon: Icons.report,
        ),
        DashboardCard(
          title: 'Total Transactions',
          value: _dashboardStats?['totalTransactions']?.toString() ?? '0',
          icon: Icons.payments,
        ),
      ],
    );
  }

  Widget _buildRecentUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Users',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RecentUsersList(users: _recentUsers),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TransactionList(transactions: _recentTransactions),
      ],
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ReportsList(reports: _recentReports),
      ],
    );
  }
}
