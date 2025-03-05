import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:ml_linalg/linalg.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart'; // ✅ For unzipping model files
import 'package:http/http.dart' as http;

class ImageSimilarity {
  static const int inputSize = 224;
  static const int featureVectorLength = 1280;

  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  // Singleton pattern
  static final ImageSimilarity _instance = ImageSimilarity._internal();
  factory ImageSimilarity() => _instance;
  ImageSimilarity._internal();

  /// ✅ Initialize the model
  Future<void> init() async {
    if (_isModelLoaded) return;

    try {
      final interpreterOptions = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;

      final modelFile = await _getModel();
      _interpreter =
          await Interpreter.fromFile(modelFile, options: interpreterOptions);
      _isModelLoaded = true;
      debugPrint('✅ MobileNet model loaded successfully.');
    } catch (e) {
      debugPrint('❌ Error loading model: $e');
      rethrow;
    }
  }

  /// ✅ Download and extract model if not exists
  Future<File> _getModel() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String modelPath = '${appDir.path}/mobilenet_v2.tflite';
    final File modelFile = File(modelPath);

    if (await modelFile.exists()) {
      return modelFile;
    }

    // Download model ZIP file
    final String zipUrl =
        'https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v2_1.0_224_quant_and_labels.zip';
    final String zipPath = '${appDir.path}/mobilenet.zip';
    final File zipFile = File(zipPath);

    debugPrint('⬇️ Downloading model...');
    final response = await http.get(Uri.parse(zipUrl));

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to download model');
    }

    await zipFile.writeAsBytes(response.bodyBytes);

    // ✅ Extract model file
    debugPrint('📦 Extracting model...');
    final Archive archive =
        ZipDecoder().decodeBytes(await zipFile.readAsBytes());

    for (final ArchiveFile file in archive) {
      if (file.name.endsWith('.tflite')) {
        final extractedFile = File(modelPath);
        await extractedFile.writeAsBytes(file.content as List<int>);
        await zipFile.delete(); // ✅ Clean up ZIP file
        return extractedFile;
      }
    }

    throw Exception('❌ Failed to extract model');
  }

  /// ✅ Process image and extract feature vector
  Future<Vector> extractFeatures(File imageFile) async {
    if (!_isModelLoaded) await init();

    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('❌ Failed to decode image');
    }

    final img.Image resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final inputBuffer = _imageToByteListUInt8(resizedImage);

    final input = [inputBuffer];
    final output = [List<double>.filled(featureVectorLength, 0)];

    _interpreter.run(input, output);

    return Vector.fromList(output[0]);
  }

  /// ✅ Convert image to normalized uint8 tensor
  Uint8List _imageToByteListUInt8(img.Image image) {
    final bytes = Uint8List(inputSize * inputSize * 3);
    int byteIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y); // Returns a Pixel object

        bytes[byteIndex++] = pixel.r.toInt(); // Extract Red
        bytes[byteIndex++] = pixel.g.toInt(); // Extract Green
        bytes[byteIndex++] = pixel.b.toInt(); // Extract Blue
      }
    }
    return bytes;
  }

  /// ✅ Calculate cosine similarity
  double calculateSimilarity(Vector features1, Vector features2) {
    final double dotProduct = features1.dot(features2);
    final double magnitude1 = features1.norm();
    final double magnitude2 = features2.norm();

    if (magnitude1 == 0 || magnitude2 == 0) return 0;
    return dotProduct / (magnitude1 * magnitude2);
  }

  /// ✅ Find most similar images from a list
  Future<List<SimilarityResult>> findSimilarImages(
      File queryImage, List<File> imageDatabase,
      {int topK = 5}) async {
    final queryFeatures = await extractFeatures(queryImage);
    final List<SimilarityResult> results = [];

    for (final image in imageDatabase) {
      final features = await extractFeatures(image);
      final similarity = calculateSimilarity(queryFeatures, features);

      results.add(SimilarityResult(image: image, similarity: similarity));
    }

    results.sort((a, b) => b.similarity.compareTo(a.similarity));
    return results.take(topK).toList();
  }

  /// ✅ Clean up resources
  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
    }
  }

  static Future<double> compareImages(String? path1, String? path2) async {
    if (path1 == null || path2 == null) return 0.0;

    try {
      // Compare available images
      return 0.5; // Default similarity score
    } catch (e) {
      return 0.0;
    }
  }
}

class SimilarityResult {
  final File image;
  final double similarity;

  SimilarityResult({required this.image, required this.similarity});

  @override
  String toString() =>
      'SimilarityResult(similarity: ${similarity.toStringAsFixed(4)})';
}
