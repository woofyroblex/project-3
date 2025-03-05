import 'package:flutter/foundation.dart';
import '../models/lost_item_model.dart';
import '../models/found_item_model.dart';
import 'image_similarity.dart';

class VisualSearch {
  static Future<List<FoundItemModel>> searchSimilarItems(
    LostItemModel lostItem,
    List<FoundItemModel> foundItems,
  ) async {
    try {
      if (lostItem.imagePath?.isEmpty ?? true) {
        return [];
      }

      List<FoundItemModel> results = [];

      for (var foundItem in foundItems) {
        if (foundItem.imagePath == null || foundItem.imagePath!.isEmpty) {
          continue;
        }

        double similarity = await ImageSimilarity.compareImages(
          lostItem.imagePath,
          foundItem.imagePath!,
        );

        if (similarity > 0.7) {
          results.add(foundItem);
        }
      }

      // Sort by similarity score (highest first)
      results.sort((a, b) => b.dateReported.compareTo(a.dateReported));
      return results;
    } catch (e) {
      debugPrint('Error in visual search: $e');
      return [];
    }
  }
}
