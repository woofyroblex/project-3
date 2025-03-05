// lib/state/ai_provider.dart

import 'package:flutter/foundation.dart';
import '../models/item_model.dart';

class AIProvider extends ChangeNotifier {
  List<ItemModel> _suggestedMatches = [];
  bool _isEnhancingImage = false;
  String? _aiError;

  List<ItemModel> get suggestedMatches => _suggestedMatches;
  bool get isEnhancingImage => _isEnhancingImage;
  String? get aiError => _aiError;

  Future<void> findInstantMatches(ItemModel item) async {
    try {
      _isEnhancingImage = true;
      _aiError = null;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      _suggestedMatches = [];

      _isEnhancingImage = false;
      notifyListeners();
    } catch (e) {
      _aiError = e.toString();
      _isEnhancingImage = false;
      notifyListeners();
    }
  }
}
