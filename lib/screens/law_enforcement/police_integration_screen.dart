import 'package:flutter/material.dart';

class PoliceIntegrationScreen extends StatefulWidget {
  @override
  _PoliceIntegrationScreenState createState() =>
      _PoliceIntegrationScreenState();
}

class _PoliceIntegrationScreenState extends State<PoliceIntegrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? caseDescription;
  String? policeStation;
  String? officerName;
  String? caseStatus = "Pending";

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted to $policeStation')),
      );
      setState(() {
        caseStatus = "Under Investigation";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Police Integration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Case Description'),
                  onSaved: (value) => caseDescription = value,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Enter case description' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Police Station Name'),
                  onSaved: (value) => policeStation = value,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Enter police station name' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Officer Name'),
                  onSaved: (value) => officerName = value,
                  validator:
                      (value) => value!.isEmpty ? 'Enter officer name' : null,
                ),
                SizedBox(height: 20),
                Text(
                  'Current Case Status: $caseStatus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitReport,
                  child: Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
