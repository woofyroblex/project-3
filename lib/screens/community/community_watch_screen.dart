import 'package:flutter/material.dart';

class CommunityWatchScreen extends StatefulWidget {
  const CommunityWatchScreen({super.key});

  @override
  CommunityWatchScreenState createState() => CommunityWatchScreenState();
}

class CommunityWatchScreenState extends State<CommunityWatchScreen> {
  List<Map<String, dynamic>> reports = [
    {
      'title': 'Lost Wallet',
      'location': 'New Delhi, India',
      'time': '2 hours ago',
      'status': 'Active',
    },
    {
      'title': 'Found Phone',
      'location': 'Mumbai, India',
      'time': '1 day ago',
      'status': 'Resolved',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Watch'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search reports by location or item',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        report['status'] == 'Active'
                            ? Icons.warning
                            : Icons.check_circle,
                        color: report['status'] == 'Active'
                            ? Colors.orange
                            : Colors.green,
                      ),
                      title: Text(report['title']),
                      subtitle:
                          Text('${report['location']} - ${report['time']}'),
                      trailing: Text(
                        report['status'],
                        style: TextStyle(
                          color: report['status'] == 'Active'
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
