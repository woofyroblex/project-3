import 'package:flutter/material.dart';

class BusinessPartnersScreen extends StatefulWidget {
  @override
  _BusinessPartnersScreenState createState() => _BusinessPartnersScreenState();
}

class _BusinessPartnersScreenState extends State<BusinessPartnersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _partners = [
    {'name': 'City Mall', 'location': 'Downtown'},
    {'name': 'International Airport', 'location': 'Terminal 3'},
    {'name': 'Central Library', 'location': 'Main Street'},
  ];
  List<Map<String, String>> _filteredPartners = [];

  @override
  void initState() {
    super.initState();
    _filteredPartners = _partners;
  }

  void _filterPartners(String query) {
    setState(() {
      _filteredPartners = _partners
          .where((partner) =>
              partner['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Partners'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Partners',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterPartners,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPartners.length,
                itemBuilder: (context, index) {
                  final partner = _filteredPartners[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.business, color: Colors.blueAccent),
                      title: Text(partner['name'] ?? ''),
                      subtitle: Text(partner['location'] ?? ''),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to partner details screen (to be implemented)
                      },
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
