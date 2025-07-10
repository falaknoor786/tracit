import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // For web, we need to load assets via network requests
      final modelJson = await _loadAsset('ml-classifier.json');
      final modelWeights = await _loadAssetBytes('ml-classifier.bin');

      // Create interpreter
      interpreter = await Interpreter.fromBuffer(modelWeights);
      _isModelLoaded = true;

      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      rethrow;
    }
  }

  Future<String> _loadAsset(String path) async {
    // For web deployment, assets are typically in the same directory
    final response = await http.get(Uri.parse('assets/$path'));
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Failed to load asset: $path');
  }

  Future<Uint8List> _loadAssetBytes(String path) async {
    final response = await http.get(Uri.parse('assets/$path'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to load asset: $path');
  }
}
