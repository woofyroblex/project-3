import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class RecentUsersList extends StatelessWidget {
  final List<UserModel> users;

  const RecentUsersList({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profileImage != null
                ? NetworkImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? Text(user.name[0].toUpperCase())
                : null,
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          // Using lastActive instead of createdAt
          trailing: Text(user.lastActive != null
              ? DateFormat('yyyy-MM-dd').format(user.lastActive!)
              : 'N/A'),
        );
      },
    );
  }
}
