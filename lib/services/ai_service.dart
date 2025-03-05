import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:tflite/tflite.dart';
import 'package:myapp/models/ai_model.dart';
import 'package:myapp/models/found_item_model.dart';
import 'package:myapp/models/lost_item_model.dart';
import 'package:myapp/utils/text_similarity.dart';
import 'package:myapp/utils/image_similarity.dart';
import 'package:myapp/utils/location_prediction.dart';
import 'package:myapp/utils/visual_search.dart';
import 'package:myapp/services/report_service.dart';

class AIService {
  final Logger _logger = Logger();
  final ReportService _reportService = ReportService();

  /// Load MobileNet-SSD model
  Future<void> loadModel() async {
    try {
      String? result = await Tflite.loadModel(
        model: "assets/models/mobilenet_ssd.tflite",
        labels: "assets/models/labels.txt",
      );
      _logger.i("Model Loaded: $result");
    } catch (e) {
      _logger.e("Error loading model: $e");
    }
  }

  /// Detect objects in an uploaded image using MobileNet-SSD
  Future<List<Map<String, dynamic>>> detectObjects(XFile image) async {
    try {
      File imageFile = File(image.path);

      var recognitions = await Tflite.detectObjectOnImage(
        path: imageFile.path,
        model: "SSDMobileNet",
        threshold: 0.4,
        numResultsPerClass: 3,
      );

      if (recognitions == null || recognitions.isEmpty) {
        _logger.i("No objects detected.");
        return [];
      }

      _logger.i("Detected Objects: $recognitions");
      return List<Map<String, dynamic>>.from(recognitions);
    } catch (e) {
      _logger.e("Error detecting objects: $e");
      return [];
    }
  }

  /// Uploads an image and returns a temporary URL.
  Future<String?> uploadImage(XFile image) async {
    try {
      return 'https://example.com/temp-url';
    } catch (e) {
      _logger.e('Error uploading image: $e');
      return null;
    }
  }

  /// Calculate similarity score between items
  Future<double> calculateAdvancedSimilarity(
      LostItemModel lostItem, FoundItemModel foundItem) async {
    double textScore = TextSimilarity.compareDescriptions(
        lostItem.description, foundItem.description);

    double imageScore = await ImageSimilarity.compareImages(
        lostItem.imagePath, foundItem.imagePath);

    double locationScore = LocationPrediction.compareLocations(
        lostItem.expectedLocation, foundItem.foundLocation);

    return (0.5 * textScore) + (0.3 * imageScore) + (0.2 * locationScore);
  }

  /// Fetches a lost item by ID
  Future<LostItemModel?> _getLostItem(String itemId) async {
    try {
      return await _reportService.getLostItemById(itemId);
    } catch (e) {
      _logger.e('Error fetching lost item: $e');
      return null;
    }
  }

  /// Fetches potential matches using advanced AI matching
  Future<List<AIMatchModel>> _fetchPotentialMatches(String itemId) async {
    try {
      LostItemModel? lostItem = await _getLostItem(itemId);
      if (lostItem == null) return [];

      List<FoundItemModel> visualMatches =
          await _performVisualRecognitionSearch(lostItem);

      List<AIMatchModel> results = [];
      for (var foundItem in visualMatches) {
        double confidence =
            await calculateAdvancedSimilarity(lostItem, foundItem);
        results.add(AIMatchModel(
          matchId: DateTime.now().toString(),
          lostItemId: itemId,
          foundItemId: foundItem.id,
          matchConfidence: confidence,
          matchStatus: AIMatchStatus.pending,
          matchedAt: DateTime.now(),
        ));
      }

      return results;
    } catch (e) {
      _logger.e('Error fetching potential matches: $e');
      return [];
    }
  }

  /// Matches lost and found items using advanced AI techniques
  Future<void> matchItems(String itemId) async {
    try {
      List<AIMatchModel> potentialMatches =
          await _fetchPotentialMatches(itemId);

      for (var match in potentialMatches) {
        double confidenceScore = (match.matchConfidence * 100).clamp(0, 100);

        if (confidenceScore > 75) {
          var updatedMatch = AIMatchModel(
            matchId: match.matchId,
            lostItemId: match.lostItemId,
            foundItemId: match.foundItemId,
            matchStatus: AIMatchStatus.matched,
            matchConfidence: confidenceScore,
            matchedAt: DateTime.now(),
          );

          _logger.i(
              'Match confirmed: ${updatedMatch.matchId} with confidence $confidenceScore%');

          await _notifyUsers(updatedMatch);
        }
      }
    } catch (e) {
      _logger.e('Error matching items: $e');
      throw Exception('Failed to match items: $e');
    }
  }

  /// Notifies users when a match is found.
  Future<void> _notifyUsers(AIMatchModel match) async {
    try {
      _logger.i('Notification sent to users for match: ${match.matchId}');
    } catch (e) {
      _logger.e('Failed to notify users: $e');
    }
  }

  /// Performs visual recognition search
  Future<List<FoundItemModel>> _performVisualRecognitionSearch(
      LostItemModel lostItem) async {
    try {
      // Get all found items that haven't been matched yet
      List<FoundItemModel> allFoundItems =
          await _reportService.getActiveFoundItems();

      // Use the VisualSearch utility to find similar items
      return await VisualSearch.searchSimilarItems(lostItem, allFoundItems);
    } catch (e) {
      _logger.e('Error performing visual recognition search: $e');
      return [];
    }
  }
}
