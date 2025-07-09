import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  String? base64Image;
  List<String> labels = [];
  bool isCameraActive = false;
  html.VideoElement? videoElement;

  @override
  void initState() {
    super.initState();

    html.window.addEventListener('tf_predictions', (event) {
      final customEvent = event as html.CustomEvent;
      final List<dynamic> predictionList = jsonDecode(customEvent.detail);

      final detectedLabels =
          predictionList.map((p) => p['class'].toString()).toList();

      setState(() => labels = detectedLabels);

      for (var label in detectedLabels) {
        saveToFirebase(label);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Added ${detectedLabels.length} items to inventory")),
      );
    });
  }

  void pickImage() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((_) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((_) {
        setState(() {
          base64Image = reader.result as String;
          labels = [];
          isCameraActive = false;
        });

        js.context.callMethod('detectObjects', [base64Image]);
      });

      reader.readAsDataUrl(file);
    });
  }

  void startCamera() async {
    setState(() {
      base64Image = null;
      labels = [];
      isCameraActive = true;
    });

    final video = html.VideoElement()
      ..width = 640
      ..height = 360
      ..autoplay = true;

    final mediaDevices = html.window.navigator.mediaDevices;
    final stream = await mediaDevices?.getUserMedia({'video': true});
    video.srcObject = stream;

    videoElement = video;

    final container = html.document.getElementById('camera-container');
    container?.children.clear();
    container?.append(video);
  }

  void captureImageFromCamera() {
    if (videoElement == null) return;

    final canvas = html.CanvasElement(
      width: videoElement!.videoWidth,
      height: videoElement!.videoHeight,
    );
    final context = canvas.context2D;

    // Mirror horizontally for selfie view
    context.translate(canvas.width!, 0);
    context.scale(-1, 1);
    context.drawImage(videoElement!, 0, 0);

    final capturedBase64 = canvas.toDataUrl('image/jpeg');

    setState(() {
      base64Image = capturedBase64;
      isCameraActive = false;
    });

    js.context.callMethod('detectObjects', [capturedBase64]);
  }

  Future<void> saveToFirebase(String label) async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': label,
      'image': base64Image,
      'created_at': Timestamp.now(),
    });
  }

  Map<String, int> summarizeLabels(List<String> labels) {
    final summary = <String, int>{};
    for (var label in labels) {
      summary[label] = (summary[label] ?? 0) + 1;
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summaryMap = summarizeLabels(labels);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.purple),
            SizedBox(width: 8),
            Text("Live Camera Feed", style: TextStyle(color: Colors.black)),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                shape: StadiumBorder(),
              ),
              child:
                  Text("Google ML Kit", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
        elevation: 1,
      ),
      body: Center(
        child: Container(
          width: 800,
          margin: EdgeInsets.only(top: 30),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Live Scanner",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: startCamera,
                    icon: Icon(Icons.videocam),
                    label: Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black12),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.upload),
                    label: Text("Upload"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: isCameraActive
                        ? Column(
                            children: [
                              Expanded(
                                child: HtmlElementView(
                                  viewType: 'camera-container',
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: captureImageFromCamera,
                                icon: Icon(Icons.camera),
                                label: Text("Capture"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ],
                          )
                        : base64Image != null
                            ? Image.memory(
                                base64Decode(base64Image!.split(',').last),
                                height: 200,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam,
                                      size: 48, color: Colors.white70),
                                  SizedBox(height: 8),
                                  Text(
                                    "Click Camera to start live feed",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (base64Image != null) {
                      js.context.callMethod('detectObjects', [base64Image]);
                    }
                  },
                  icon: Icon(Icons.search),
                  label: Text("Scan Items"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: StadiumBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (labels.isNotEmpty) ...[
                Text("Detected Items:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: labels.map((label) {
                    return Chip(label: Text(label));
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text("Summary:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...summaryMap.entries.map((entry) => Text(
                      '${entry.key} x${entry.value}',
                      style: TextStyle(fontSize: 16),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
