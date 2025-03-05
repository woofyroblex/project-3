import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<PaymentModel>> _paymentHistory;

  @override
  void initState() {
    super.initState();
    _paymentHistory = _paymentService.fetchPaymentHistory('currentUserId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
      ),
      body: FutureBuilder<List<PaymentModel>>(
        future: _paymentHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching payment history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No payment history available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final payment = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.payment, color: Colors.green),
                    title: Text('Payment ID: ${payment.paymentId}'),
                    subtitle: Text(
                        'Amount: ₹${payment.amount}\nStatus: ${payment.status}\nDate: ${payment.timestamp.toLocal()}'),
                    trailing: Icon(
                      payment.status == 'completed'
                          ? Icons.check_circle
                          : Icons.pending,
                      color: payment.status == 'completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
