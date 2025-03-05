import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: notificationService.getUserNotifications(
                "USER_ID"), // Replace with actual user ID logic
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final notifications = snapshot.data!;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['message']),
                    trailing: notification['isRead']
                        ? Icon(Icons.done, color: Colors.green)
                        : Icon(Icons.mark_email_unread, color: Colors.red),
                    onTap: () {
                      notificationService
                          .markNotificationAsRead(notification['id']);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
