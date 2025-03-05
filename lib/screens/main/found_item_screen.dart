import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportFoundItemScreen extends StatefulWidget {
  @override
  _ReportFoundItemScreenState createState() => _ReportFoundItemScreenState();
}

class _ReportFoundItemScreenState extends State<ReportFoundItemScreen> {
  File? _image;
  File? _video;
  final picker = ImagePicker();

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
    }
  }

  void _submitReport() {
    // Here, handle submission logic, like saving to a database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Found Item Report Submitted Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Found Item')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Photo'),
            ),
            if (_image != null) Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Upload Video'),
            ),
            if (_video != null) Text('Video Selected: ${_video!.path}'),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time Found'),
            ),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(labelText: 'Country Found'),
            ),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(labelText: 'State'),
            ),
            TextField(
              controller: _districtController,
              decoration: InputDecoration(labelText: 'District'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Most Accurate Location'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Day & Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
