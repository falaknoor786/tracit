import 'dart:async'; // For Completer in _uploadImage
import 'dart:convert';
import 'dart:html' as html; // Only for web
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:camera/camera.dart'; // Camera package for live feed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if running on web
import 'package:flutter/material.dart';
import 'package:inventory_management_system/v2/DashboardPage.dart';

// --- MAIN APPLICATION ENTRY POINT ---

class xMyApp extends StatelessWidget {
  const xMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracit.ai Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define consistent text themes for consistency
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C2A9A)),
          titleLarge: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C2A9A)),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
          labelLarge: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      home: DashboardPage(), // Start with the DashboardPage
      //home: ObjectDetectionScreen(), // Start with the DashboardPage
      //home: InventoryDashboardScreen(), // Start with the DashboardPage
    );
  }
}

// --- LIVE CAMERA FEED CARD WIDGET ---
class LiveCameraFeedCard extends StatefulWidget {
  const LiveCameraFeedCard({super.key});

  @override
  _LiveCameraFeedCardState createState() => _LiveCameraFeedCardState();
}

Future<Map<String, int>> getLabelCountsFromBase64Image(
    String base64Image) async {
  final completer = Completer<Map<String, int>>();

  void predictionListener(html.Event event) {
    final customEvent = event as html.CustomEvent;
    final List<dynamic> predictionList = jsonDecode(customEvent.detail);

    final labels = predictionList.map((p) => p['class'].toString());

    final labelCounts = <String, int>{};

    for (var label in labels) {
      labelCounts[label] = (labelCounts[label] ?? 0) + 1;
    }

    html.window.removeEventListener('tf_predictions', predictionListener);
    completer.complete(labelCounts);
  }

  html.window.addEventListener('tf_predictions', predictionListener);

  js.context.callMethod('detectObjects', [base64Image]);

  return completer.future;
}

class _LiveCameraFeedCardState extends State<LiveCameraFeedCard> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  Uint8List? _uploadedImageBytes;

  // Define consistent colors from the main DashboardPage
  static const Color _primaryPurple = Color(0xFF4C2A9A); // Deep purple
  static const Color _mediumPurple = Color(0xFF8A2BE2); // Medium purple
  static const Color _accentGreen =
      Color(0xFF4CAF50); // Standard green for action

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _errorMessage =
          "Camera not fully supported on this platform without additional setup.";
    }
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

  List<String> labels = [];
  String base64Image = "";
  Future<void> saveToFirebase(String label) async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': label,
      'image': base64Image,
      'created_at': Timestamp.now(),
    });
  }

  Future<void> _initializeCamera() async {
    if (_isProcessing || _isCameraInitialized) return;

    setState(() {
      _errorMessage = null;
      _isProcessing = true;
      _uploadedImageBytes = null;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device.';
          _isProcessing = false;
        });
        return;
      }

      CameraDescription selectedCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera Error: $e';
        _isCameraInitialized = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _takePictureAndProcess() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      setState(() {
        _errorMessage = 'Camera not initialized.';
      });
      return;
    }
    if (_cameraController!.value.isTakingPicture || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);
      // detectAndShowCounts(base64Image);

      //  Example: Save to Firestore (requires Firebase setup)
      await FirebaseFirestore.instance.collection('inventory').add({
        'image': base64Image,
        'source': 'camera',
        'timestamp': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Image captured & saved to Firestore (example)')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error capturing image: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Map<String, int> groupedLabels = {};

  Future<void> _uploadImage() async {
    if (!kIsWeb) {
      setState(() {
        _errorMessage = 'Image upload is only supported on web.';
      });
      return;
    }
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      final completer = Completer<Uint8List?>();
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          completer.complete(null); // No file selected
          return;
        }

        final file = files[0];
        final reader = html.FileReader();

        reader.onError.listen((error) {
          completer.completeError('Failed to read image: $error');
        });

        reader.onLoadEnd.listen((_) {
          if (reader.readyState == html.FileReader.DONE) {
            completer.complete(reader.result as Uint8List);
          }
        });

        reader.readAsArrayBuffer(file);
      });

      final Uint8List? bytes = await completer.future;

      if (bytes != null) {
        final String base64Image = base64Encode(bytes);

        // Example: Save to Firestore (requires Firebase setup)
        await FirebaseFirestore.instance.collection('inventory').add({
          'image': base64Image,
          'source': 'upload',
          'timestamp': Timestamp.now(),
        });

        if (mounted) {
          setState(() {
            _uploadedImageBytes = bytes;
            _errorMessage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Image uploaded and saved to Firestore (example)!')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Image upload cancelled.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Upload error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _stopCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      setState(() {
        _cameraController = null;
        _isCameraInitialized = false;
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8, // Slightly higher elevation for a premium feel
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // More rounded corners
      // No margin here as it's handled by padding in DashboardPage
      child: Padding(
        padding: const EdgeInsets.all(30.0), // Increased inner padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 30), // Increased spacing
            _buildControls(),
            const SizedBox(height: 30), // Increased spacing
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // Adjusted padding
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            _buildPreview(),
            const SizedBox(height: 30), // Increased spacing
            _buildScanButton(),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for LiveCameraFeedCard ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.camera_alt,
                size: 32, color: _primaryPurple), // Larger icon
            SizedBox(width: 15), // Increased spacing
            Text(
              'Live Camera Feed',
              style: TextStyle(
                fontSize: 24, // Larger font
                fontWeight: FontWeight.bold,
                color: _primaryPurple, // Consistent color
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8), // More padding
          decoration: BoxDecoration(
            color: _mediumPurple, // Use the medium purple
            borderRadius: BorderRadius.circular(25), // More rounded
          ),
          child: const Text(
            'Google ML Kit',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15, // Slightly larger font
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Controls',
          style: TextStyle(
            fontSize: 20, // Larger font
            fontWeight: FontWeight.w700, // Bolder
            color: Colors.black87, // Stronger text color
          ),
        ),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.videocam,
              label: _isCameraInitialized ? 'Stop Camera' : 'Start Camera',
              onPressed: kIsWeb && !_isProcessing
                  ? (_isCameraInitialized ? _stopCamera : _initializeCamera)
                  : null,
              isLoading: _isProcessing && !_isCameraInitialized,
            ),
            const SizedBox(width: 16), // Increased spacing
            _buildActionButton(
              icon: Icons.upload_file,
              label: 'Upload Image', // Changed label for clarity
              onPressed: kIsWeb && !_isProcessing ? _uploadImage : null,
              isLoading: _isProcessing && kIsWeb && _cameraController == null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 400, // Slightly taller
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryPurple
            .withOpacity(0.9), // Use primary purple with slight opacity
        borderRadius: BorderRadius.circular(16), // Consistent rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isCameraInitialized &&
              _cameraController != null &&
              _cameraController!.value.isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_cameraController!),
            )
          : _uploadedImageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _uploadedImageBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                  ),
                )
              : Center(
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off,
                                size: 70,
                                color: Colors
                                    .white60), // Larger icon, slightly less opaque
                            const SizedBox(height: 20), // Increased spacing
                            const Text(
                              'Click Camera to start live feed', // Changed text as per screenshot
                              style: TextStyle(
                                  color:
                                      Colors.white70, // Slightly brighter text
                                  fontSize: 18), // Larger font
                            ),
                            // No "(Web only)" in the screenshot, so removed.
                          ],
                        ),
                ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isCameraInitialized && !_isProcessing)
            ? _takePictureAndProcess
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentGreen, // Consistent green for action
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(vertical: 18), // More vertical padding
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35)), // More rounded
          elevation: 5, // Add some elevation
        ),
        child: _isProcessing && _isCameraInitialized
            ? const SizedBox(
                width: 28, // Slightly larger spinner
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3, // Thicker stroke
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner,
                      size: 24), // Changed icon to match "Scan Items"
                  SizedBox(width: 10), // Increased spacing
                  Text('Scan Items',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold)), // Changed text to "Scan Items"
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12), // More padding
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)), // More rounded
        side: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5), // Lighter, slightly thicker border
        backgroundColor: Colors.white, // Explicit white background
        foregroundColor: _primaryPurple, // Text and icon color
        elevation: 2, // Subtle elevation
      ),
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
                  width: 22, // Slightly larger spinner
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _primaryPurple), // Consistent purple
                )
              : Icon(icon, size: 22, color: _primaryPurple), // Larger icon
          const SizedBox(width: 10), // Increased spacing
          Text(label,
              style: const TextStyle(
                  color: _primaryPurple,
                  fontSize: 16)), // Consistent font size and color
        ],
      ),
    );
  }
}

// --- POINT CALCULATOR CARD WIDGET ---
class PointCalculatorCard extends StatefulWidget {
  const PointCalculatorCard({super.key});

  @override
  State<PointCalculatorCard> createState() => _PointCalculatorCardState();
}

class _PointCalculatorCardState extends State<PointCalculatorCard> {
  int totalItems = 0;
  int totalPoints = 0;
  final TextEditingController _cardNoController = TextEditingController();

  // Define consistent colors from the main DashboardPage
  static const Color _primaryPurple = Color(0xFF4C2A9A); // Deep purple
  static const Color _accentGreen =
      Color(0xFF4CAF50); // Standard green for action

  @override
  void dispose() {
    _cardNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: _primaryPurple, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Point Calculator',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1, color: Colors.grey),
            _buildInfoRow('Total Items:', totalItems.toString()),
            const SizedBox(height: 10),
            _buildInfoRow('Total Points:', totalPoints.toString()),
            const SizedBox(height: 20),
            Text(
              'Card Number',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cardNoController,
              decoration: InputDecoration(
                hintText: 'Scan or enter card number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primaryPurple, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Check Balance logic
                  print('Check Balance for: ${_cardNoController.text}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple, // Purple button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                child:
                    const Text('Check Balance', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Redeem Items logic
                  print('Redeem Items pressed');
                  // Example: increase items and points
                  setState(() {
                    totalItems += 1;
                    totalPoints += 50;
                  });
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label:
                    const Text('Redeem Items', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentGreen, // Green button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.black87),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: _primaryPurple),
        ),
      ],
    );
  }
}

// --- DETECTED ITEMS SECTION WIDGET ---
class DetectedItemsSection extends StatelessWidget {
  const DetectedItemsSection({super.key});

  // Define consistent colors from the main DashboardPage
  static const Color _primaryPurple = Color(0xFF4C2A9A); // Deep purple

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes,
                    color: _primaryPurple, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Detected Items',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1, color: Colors.grey),
            // Placeholder for detected items list
            Container(
              height:
                  150, // Example height, will be dynamic with a ListView.builder
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checklist, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'No items detected yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Scan or upload an image to see results.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // You would typically have a ListView.builder here for actual items
            // Example:
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: detectedItems.length,
            //   itemBuilder: (context, index) {
            //     final item = detectedItems[index];
            //     return ListTile(
            //       leading: Icon(Icons.check_box),
            //       title: Text(item.name),
            //       trailing: Text('x ${item.quantity}'),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

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
