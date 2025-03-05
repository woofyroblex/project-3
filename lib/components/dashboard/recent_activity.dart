// recent_activity.dart
import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  final List<String> activities;

  const RecentActivity({required this.activities, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...activities.map((activity) => ListTile(
              leading: Icon(Icons.history),
              title: Text(activity),
            )),
      ],
    );
  }
}
