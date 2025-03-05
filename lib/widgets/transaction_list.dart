import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: const Icon(Icons.payment),
          title: Text('Amount: \$${transaction.amount.toStringAsFixed(2)}'),
          subtitle: Text('Status: ${transaction.status}'),
          trailing: Text(transaction.timestamp.toString().split(' ')[0]),
        );
      },
    );
  }
}
