//lib/screens/ai/ai_matching_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../state/ai_provider.dart';
import '../../models/item_model.dart';

import '../../services/ai_service.dart';

class AIMatchingScreen extends StatefulWidget {
  const AIMatchingScreen({super.key}); // Fixed super parameter syntax

  @override
  AIMatchingScreenState createState() => AIMatchingScreenState();
}

class AIMatchingScreenState extends State<AIMatchingScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final AIService _aiService = AIService();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _photoUrl;
  String? _videoUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    if (!mounted) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String? uploadedUrl = await _aiService.uploadImage(image);
        if (mounted) {
          setState(() {
            _photoUrl = uploadedUrl;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Report Lost Item"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Item Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Electronics',
                  'Jewelry',
                  'Documents',
                  'Clothing',
                  'Other'
                ].map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date Lost'),
                subtitle: Text(
                  _selectedDate.toString().split(' ')[0],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Exact Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                    icon: const Icon(Icons.photo_camera),
                    label: Text(_isLoading ? 'Uploading...' : 'Add Photo'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Implement video picker
                      // Similar to photo picker
                      // setState(() => _videoUrl = uploadedUrl);
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Add Video'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final item = ItemModel(
                    itemId: DateTime.now().toString(),
                    userId: 'current_user_id',
                    title: _titleController.text,
                    description: _descriptionController.text,
                    status: ItemStatus.pending,
                    category: _selectedCategory ?? 'Other',
                    imageUrl: _photoUrl ?? '',
                    photoUrl: _photoUrl ?? '',
                    videoUrl: _videoUrl ?? '',
                    confidence: 0.0,
                    dateTime: _selectedDate,
                    country: _countryController.text,
                    state: _stateController.text,
                    district: _districtController.text,
                    exactLocation: _locationController.text,
                  );
                  aiProvider.findInstantMatches(item);
                },
                child: const Text('Find Matches'),
              ),
              const SizedBox(height: 20),
              if (aiProvider.isEnhancingImage)
                const Center(child: CircularProgressIndicator())
              else if (aiProvider.aiError != null)
                Text("Error: ${aiProvider.aiError}")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: aiProvider.suggestedMatches.length,
                  itemBuilder: (context, index) {
                    final match = aiProvider.suggestedMatches[index];
                    return ListTile(
                      leading: match.imageUrl.isNotEmpty
                          ? Image.network(match.imageUrl)
                          : const Icon(Icons.image_not_supported),
                      title: Text(match.description),
                      subtitle: Text(
                          "Matched Confidence: ${match.confidence.toStringAsFixed(2)}%"),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
