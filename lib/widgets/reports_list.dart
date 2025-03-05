import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportsList extends StatelessWidget {
  final List<ReportModel> reports;

  const ReportsList({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ListTile(
          leading: const Icon(Icons.report),
          title: Text(report.itemType),
          subtitle: Text(report.description),
          trailing: Text(report.dateReported.toString().split(' ')[0]),
        );
      },
    );
  }
}
