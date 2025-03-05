// report_service.dart
import 'package:lafa/models/lost_item_model.dart';
import 'package:lafa/models/found_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<LostItemModel?> getLostItemById(String itemId) async {
    try {
      final docSnapshot =
          await _firestore.collection('lost_items').doc(itemId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return LostItemModel.fromJson({
        'id': docSnapshot.id,
        ...docSnapshot.data() ?? {},
      });
    } catch (e) {
      throw Exception('Failed to fetch lost item: $e');
    }
  }

  Future<List<FoundItemModel>> getActiveFoundItems() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('found_items')
          .where('status', isEqualTo: 'active')
          .orderBy('dateReported', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoundItemModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active found items: $e');
    }
  }

  Future<List<dynamic>> getUserReports(String userId) async {
    try {
      // Fetch lost item reports
      final lostItemsQuery = await _firestore
          .collection('lost_items')
          .where('userId', isEqualTo: userId)
          .orderBy('dateOfLoss', descending: true)
          .get();

      // Fetch found item reports
      final foundItemsQuery = await _firestore
          .collection('found_items')
          .where('userId', isEqualTo: userId)
          .orderBy('dateOfFound', descending: true)
          .get();

      // Convert to models
      final lostItems = lostItemsQuery.docs
          .map((doc) => LostItemModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      final foundItems = foundItemsQuery.docs
          .map((doc) => FoundItemModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Combine and sort by date
      final allReports = [...lostItems, ...foundItems];
      allReports.sort((a, b) {
        final DateTime aDate = a is LostItemModel
            ? a.dateOfLoss
            : (a as FoundItemModel).dateReported;
        final DateTime bDate = b is LostItemModel
            ? b.dateOfLoss
            : (b as FoundItemModel).dateReported;
        return bDate.compareTo(aDate);
      });

      return allReports;
    } catch (e) {
      throw Exception('Failed to fetch user reports: $e');
    }
  }
}
