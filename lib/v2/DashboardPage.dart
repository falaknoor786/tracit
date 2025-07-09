// --- DASHBOARD PAGE (MAIN SCREEN) ---
import 'package:flutter/material.dart';

import '../LiveScannerPage.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTab =
      1; // 0 for Barcode Mode, 1 for Photo Upload (Live Camera Feed)

  // Define consistent colors for the entire app based on your app bar
  static const Color _primaryPurple = Color(0xFF4C2A9A); // Deep purple
  static const Color _mediumPurple = Color(0xFF8A2BE2); // Medium purple
  static const Color _accentGreen =
      Color(0xFF4CAF50); // Standard green for action

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Your custom AppBar
      backgroundColor: const Color(0xFFF0F2F5), // Light grey background
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopPreviewHeader(), // Top "Mobile Preview" section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align top of columns
                children: [
                  // Left Column: Live Scan, Point Calculator, Detected Items
                  Expanded(
                    flex: 2, // Allocate 2 parts of space
                    child: Column(
                      children: [
                        _buildLiveScanTab(), // "Live Scan" header
                        const SizedBox(height: 20),
                        const PointCalculatorCard(), // Point Calculator widget
                        const SizedBox(height: 20),
                        const DetectedItemsSection(), // Detected Items widget
                      ],
                    ),
                  ),
                  const SizedBox(width: 24), // Spacing between columns
                  // Right Column: Barcode Mode/Photo Upload tabs, Live Camera Feed
                  Expanded(
                    flex: 4, // Allocate 4 parts of space (wider)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barcode Mode / Photo Upload Tabs
                        _buildModeTabs(),
                        const SizedBox(height: 20),
                        // Conditional content based on selected tab
                        if (_selectedTab == 0)
                          _buildBarcodeScannerPlaceholder(), // Placeholder for barcode scanner
                        if (_selectedTab == 1)
                          //ObjectDetectionScreen()
                          const LiveCameraFeedCard(), // Your main Live Camera Feed Card
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for DashboardPage ---

  Widget _buildTopPreviewHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.blueGrey, size: 24),
              const SizedBox(width: 8),
              Text(
                'Tracit.ai Mobile Preview',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeatureTag(context, 'Barcode Scanning'),
              const SizedBox(width: 12),
              _buildFeatureTag(context, 'Object Detection'),
              const SizedBox(width: 12),
              _buildFeatureTag(context, 'Firebase Sync'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Use appropriate icons if available, otherwise just text
          if (text == 'Barcode Scanning')
            const Icon(Icons.qr_code, size: 16, color: Colors.grey),
          if (text == 'Object Detection')
            const Icon(Icons.visibility, size: 16, color: Colors.grey),
          if (text == 'Firebase Sync')
            const Icon(Icons.cloud, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScanTab() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.document_scanner, color: _primaryPurple, size: 24),
            const SizedBox(width: 12),
            Text(
              'Live Scan',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: _primaryPurple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTabButton(
              label: 'Barcode Mode',
              icon: Icons.qr_code_scanner,
              index: 0,
            ),
          ),
          Expanded(
            child: _buildModeTabButton(
              label: 'Photo Upload',
              icon: Icons.camera_alt,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabButton({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeScannerPlaceholder() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 500, // Adjust height as needed
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Barcode Scanner will go here',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Switch to "Photo Upload" for camera feed.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
