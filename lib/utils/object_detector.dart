import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ObjectDetector {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  static const String modelFileName = 'mobilenet_ssd.tflite';
  static const String labelsFileName = 'labels.txt';
  List<String> _labels = [];

  static final ObjectDetector _instance = ObjectDetector._internal();
  factory ObjectDetector() => _instance;
  ObjectDetector._internal();

  Future<void> init() async {
    if (_isModelLoaded) return;

    try {
      final modelFile = await _loadModel();
      await _loadLabels();
      _interpreter = await Interpreter.fromFile(modelFile);
      _isModelLoaded = true;
      debugPrint('✅ Object Detection Model and Labels Loaded');
    } catch (e) {
      debugPrint('❌ Error Loading Model or Labels: $e');
      rethrow;
    }
  }

  Future<File> _loadModel() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File modelFile = File('${appDir.path}/$modelFileName');

    if (await modelFile.exists()) return modelFile;

    final response =
        await http.get(Uri.parse('https://example.com/$modelFileName'));
    if (response.statusCode == 200) {
      await modelFile.writeAsBytes(response.bodyBytes);
      return modelFile;
    } else {
      throw Exception('❌ Failed to Download Model');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final File labelsFile = File('${appDir.path}/$labelsFileName');

      if (await labelsFile.exists()) {
        String content = await labelsFile.readAsString();
        _labels =
            content.split('\n').where((label) => label.isNotEmpty).toList();
      } else {
        // Default labels if file not found
        _labels = ['Background', 'Person', 'Vehicle', 'Animal', 'Object'];
      }
    } catch (e) {
      debugPrint('❌ Error Loading Labels: $e');
      // Fallback labels
      _labels = ['Background', 'Person', 'Vehicle', 'Animal', 'Object'];
    }
  }

  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (!_isModelLoaded) await init();

    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception('❌ Failed to decode image');

    final inputBuffer = _imageToByteList(decodedImage);
    final output = List.generate(10, (index) => List.filled(6, 0.0));

    _interpreter.run([inputBuffer], [output]);

    return _parseResults(output);
  }

  Uint8List _imageToByteList(img.Image image) {
    final bytes = Uint8List(224 * 224 * 3);
    int index = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixelSafe(x, y);
        bytes[index++] = pixel.r.toInt();
        bytes[index++] = pixel.g.toInt();
        bytes[index++] = pixel.b.toInt();
      }
    }
    return bytes;
  }

  List<DetectionResult> _parseResults(List<List<double>> rawOutput) {
    List<DetectionResult> results = [];
    for (var detection in rawOutput) {
      final confidence = detection[2];
      if (confidence > 0.5) {
        final labelIndex = detection[1].toInt();
        final label =
            labelIndex < _labels.length ? _labels[labelIndex] : 'Unknown';

        results.add(DetectionResult(
          label: label,
          confidence: confidence,
          x: detection[3],
          y: detection[4],
          width: detection[5],
          height: detection[6],
        ));
      }
    }
    return results;
  }

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
    }
  }
}

class DetectionResult {
  final String label;
  final double confidence;
  final double x, y, width, height;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
