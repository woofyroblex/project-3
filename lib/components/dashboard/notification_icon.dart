// notification_icon.dart
import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final int unreadCount;

  const NotificationIcon({required this.unreadCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.notifications, size: 30),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
