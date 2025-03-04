import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import
import '../../models/lost_item_model.dart';

class LostItemDetailsScreen extends StatelessWidget {
  final LostItemModel item;

  const LostItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Item Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Image.network(
                item.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text('Description: ${item.description}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Date Lost: ${_formatDate(item.dateOfLoss)}'),
            const SizedBox(height: 8),
            Text('Location: ${item.locationLost}'),
            const SizedBox(height: 8),
            Text('Status: ${item.status.toUpperCase()}'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
