import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportLostItemScreen extends StatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  ReportLostItemScreenState createState() => ReportLostItemScreenState();
}

class ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _placesTraveled = 0;
  List<TextEditingController> _placesControllers = [];
  XFile? _photo;
  XFile? _video;
  final picker = ImagePicker();

  // Form Fields
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickMedia(ImageSource source, bool isPhoto) async {
    final pickedFile = isPhoto
        ? await picker.pickImage(source: source)
        : await picker.pickVideo(source: source);
    setState(() {
      if (isPhoto) {
        _photo = pickedFile;
      } else {
        _video = pickedFile;
      }
    });
  }

  void _updatePlaces(int count) {
    setState(() {
      _placesTraveled = count;
      _placesControllers = List.generate(count, (_) => TextEditingController());
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lost Item Report Submitted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Lost Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Photo:'),
              ElevatedButton(
                onPressed: () => _pickMedia(ImageSource.gallery, true),
                child: Text('Pick Photo'),
              ),
              if (_photo != null) Image.file(File(_photo!.path)),
              SizedBox(height: 10),
              Text('Upload Video:'),
              ElevatedButton(
                onPressed: () => _pickMedia(ImageSource.gallery, false),
                child: Text('Pick Video'),
              ),
              if (_video != null) Text('Video selected: ${_video!.name}'),
              SizedBox(height: 20),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country of Loss'),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'Expected State'),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'Expected District'),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration:
                    InputDecoration(labelText: 'Most Accurate Location'),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Pick Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
              ),
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(_selectedTime == null
                    ? 'Pick Time'
                    : _selectedTime!.format(context)),
              ),
              SizedBox(height: 20),
              Text('Places Traveled:'),
              DropdownButton<int>(
                value: _placesTraveled,
                onChanged: (value) => _updatePlaces(value ?? 0),
                items: List.generate(
                    6,
                    (index) => DropdownMenuItem(
                          value: index,
                          child: Text('$index'),
                        )),
              ),
              ..._placesControllers.map((controller) => TextFormField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Place Traveled'),
                  )),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReport,
                  child: Text('Submit Report'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
