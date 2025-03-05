import 'dart:math' as math;

class TextSimilarity {
  static double compareDescriptions(String description1, String description2) {
    if (description1.isEmpty && description2.isEmpty) return 1.0;
    if (description1.isEmpty || description2.isEmpty) return 0.0;

    // Preprocess the texts
    final text1 = _preprocessText(description1);
    final text2 = _preprocessText(description2);

    // Calculate Jaccard similarity
    final set1 = text1.toSet();
    final set2 = text2.toSet();

    final intersection = set1.intersection(set2);
    final union = set1.union(set2);

    if (union.isEmpty) return 0.0;

    // Calculate both Jaccard and word count similarity
    final jaccardSimilarity = intersection.length / union.length;
    final wordCountSimilarity = _calculateWordCountSimilarity(text1, text2);

    // Return weighted average of both metrics
    return (jaccardSimilarity * 0.7) + (wordCountSimilarity * 0.3);
  }

  static List<String> _preprocessText(String text) {
    // Convert to lowercase
    text = text.toLowerCase();

    // Remove special characters and extra spaces
    text = text.replaceAll(RegExp(r'[^\w\s]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove common stop words
    final stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to'
    };
    return text
        .split(' ')
        .where((word) => word.isNotEmpty && !stopWords.contains(word))
        .toList();
  }

  static double _calculateWordCountSimilarity(
      List<String> words1, List<String> words2) {
    final maxLength = math.max(words1.length, words2.length);
    if (maxLength == 0) return 0.0;

    final lengthDifference = (words1.length - words2.length).abs();
    return 1 - (lengthDifference / maxLength);
  }
}
