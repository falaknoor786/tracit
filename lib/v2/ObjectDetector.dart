import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

class ObjectDetector {
  Completer<List<String>>? _predictionCompleter;

  ObjectDetector() {
    // Listen once for prediction event
    html.window.addEventListener('tf_predictions', (event) {
      if (_predictionCompleter == null) return;

      final customEvent = event as html.CustomEvent;
      final List<dynamic> predictionList = jsonDecode(customEvent.detail);
      final List<String> detectedLabels =
          predictionList.map((p) => p['class'].toString()).toList();

      _predictionCompleter?.complete(detectedLabels);
      _predictionCompleter = null;
    });
  }

  /// Takes a base64 image and returns a map of label: count
  Future<Map<String, int>> detect(String base64Image) async {
    _predictionCompleter = Completer<List<String>>();

    // Call JS object detection method
    js.context.callMethod('detectObjects', [base64Image]);

    final labels = await _predictionCompleter!.future;

    // Count each label
    final Map<String, int> summary = {};
    for (var label in labels) {
      summary[label] = (summary[label] ?? 0) + 1;
    }

    return summary;
  }
}
