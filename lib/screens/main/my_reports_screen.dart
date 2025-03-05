import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/report_service.dart';
import '../../models/lost_item_model.dart';
import '../../models/found_item_model.dart';
import '../../state/user_provider.dart';

import '../details/lost_item_details_screen.dart';
import '../details/found_item_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ReportService _reportService = ReportService();
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final reports = await _reportService.getUserReports(userId);

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  if (report is LostItemModel) {
                    return _buildLostItemTile(report);
                  } else if (report is FoundItemModel) {
                    return _buildFoundItemTile(report);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }

  Widget _buildLostItemTile(LostItemModel item) {
    return ListTile(
      leading: const Icon(Icons.search_off),
      title: Text('Lost: ${item.description}'),
      subtitle: Text('Lost on: ${_formatDate(item.dateOfLoss)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToItemDetails(item),
    );
  }

  Widget _buildFoundItemTile(FoundItemModel item) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text('Found: ${item.description}'),
      subtitle: Text('Found on: ${_formatDate(item.dateReported)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToItemDetails(item),
    );
  }

  void _navigateToItemDetails(dynamic item) {
    final route = MaterialPageRoute(
      builder: (context) => item is LostItemModel
          ? LostItemDetailsScreen(item: item)
          : FoundItemDetailsScreen(item: item),
    );
    Navigator.push(context, route);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
