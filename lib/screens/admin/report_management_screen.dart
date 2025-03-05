import 'package:flutter/material.dart';

class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({super.key});

  @override
  ReportManagementScreenState createState() => ReportManagementScreenState();
}

class ReportManagementScreenState extends State<ReportManagementScreen> {
  List<Map<String, String>> reports = [
    {'id': '1', 'title': 'Lost Wallet', 'status': 'Pending'},
    {'id': '2', 'title': 'Found Keys', 'status': 'Resolved'},
    {'id': '3', 'title': 'Lost Phone', 'status': 'Flagged'},
  ];

  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredReports = reports.where((report) {
      final matchesSearch =
          report['title']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus =
          selectedStatus == 'All' || report['status'] == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Report Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(labelText: 'Search Reports'),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedStatus,
          items: ['All', 'Pending', 'Resolved', 'Flagged']
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) => setState(() => selectedStatus = value!),
        ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, String> report) {
    Color statusColor;
    switch (report['status']) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'Flagged':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(report['title']!),
        subtitle: Text('Status: ${report['status']}'),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleReportAction(report['id']!, action),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'Resolve', child: Text('Mark as Resolved')),
            PopupMenuItem(value: 'Flag', child: Text('Flag Report')),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(report['title']![0]),
        ),
      ),
    );
  }

  void _handleReportAction(String reportId, String action) {
    setState(() {
      final reportIndex = reports.indexWhere((r) => r['id'] == reportId);
      if (reportIndex != -1) {
        if (action == 'Resolve') {
          reports[reportIndex]['status'] = 'Resolved';
        } else if (action == 'Flag') {
          reports[reportIndex]['status'] = 'Flagged';
        }
      }
    });
  }
}
