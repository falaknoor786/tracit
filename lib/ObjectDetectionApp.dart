import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:js/js.dart';

// JS interop call to JavaScript function in index.html
@JS('detectObjects')
external void detectObjects(String base64Image);

void main() {
  runApp(const ObjectDetectionApp());
}

class ObjectDetectionApp extends StatelessWidget {
  const ObjectDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog vs Cat vs Panda Classifier',
      home: const ObjectDetectionzz(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ObjectDetectionzz extends StatefulWidget {
  const ObjectDetectionzz({super.key});

  @override
  State<ObjectDetectionzz> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionzz> {
  String _rawOutput = '';
  String _label = '';
  String _confidence = '';
  Uint8List? _imageBytes;

  final List<String> classLabels = ['Cat', 'Dog', 'Panda'];

  @override
  void initState() {
    super.initState();

    // Listen for the result from JS
    window.addEventListener('tf_predictions', (event) {
      final CustomEvent e = event as CustomEvent;
      final String jsonResult = e.detail;

      try {
        final parsed = json.decode(jsonResult);
        if (parsed is List) {
          _processPrediction(parsed.cast<double>());
        } else if (parsed is Map && parsed.containsKey('error')) {
          setState(() {
            _rawOutput = "Error: ${parsed['error']}";
            _label = '';
            _confidence = '';
          });
        }
      } catch (err) {
        setState(() {
          _rawOutput = 'Failed to parse prediction: $err';
          _label = '';
          _confidence = '';
        });
      }
    });
  }

  void _processPrediction(List<double> predictions) {
    final maxScore = predictions.reduce((a, b) => a > b ? a : b);
    final topIndex = predictions.indexOf(maxScore);

    setState(() {
      _rawOutput = predictions.toString();
      _label = classLabels[topIndex];
      _confidence = (maxScore * 100).toStringAsFixed(2) + '%';
    });
  }

  void _pickImageAndDetect() {
    final input = FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file == null) return;

      final reader = FileReader();
      reader.readAsDataUrl(file);

      reader.onLoadEnd.listen((e) {
        final base64Str = reader.result as String;

        setState(() {
          _imageBytes = base64Decode(base64Str.split(',').last);
          _rawOutput = '';
          _label = '';
          _confidence = '';
        });

        detectObjects(base64Str);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog, Cat, Panda Classifier'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImageAndDetect,
                  icon: const Icon(Icons.upload),
                  label: const Text("Select Image"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                const SizedBox(height: 20),
                if (_imageBytes != null) Image.memory(_imageBytes!, width: 300),
                const SizedBox(height: 20),
                if (_label.isNotEmpty) ...[
                  const Text("Prediction:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Label: $_label", style: const TextStyle(fontSize: 20)),
                  Text("Confidence: $_confidence",
                      style: const TextStyle(fontSize: 20)),
                ],
                const SizedBox(height: 20),
                if (_rawOutput.isNotEmpty) ...[
                  const Text("Raw Model Output:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(_rawOutput,
                      style: const TextStyle(fontSize: 14)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
