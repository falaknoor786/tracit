import 'package:flutter/material.dart';

import '../LiveScannerPage.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTab = 1;

  static const Color _primaryPurple = Color(0xFF4C2A9A);
  static const Color _mediumPurple = Color(0xFF8A2BE2);
  static const Color _accentGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFFF0F2F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          bool isMobile = screenWidth < 600;
          bool isTablet = screenWidth >= 600 && screenWidth < 1024;
          bool isDesktop = screenWidth >= 1024;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildTopPreviewHeader(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildLiveScanTab(),
                            const SizedBox(height: 20),
                            const PointCalculatorCard(),
                            const SizedBox(height: 20),
                            const DetectedItemsSection(),
                            const SizedBox(height: 24),
                            _buildModeTabs(),
                            const SizedBox(height: 20),
                            _selectedTab == 0
                                ? _buildBarcodeScannerPlaceholder()
                                : const LiveCameraFeedCard(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildLiveScanTab(),
                                  const SizedBox(height: 20),
                                  const PointCalculatorCard(),
                                  const SizedBox(height: 20),
                                  const DetectedItemsSection(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildModeTabs(),
                                  const SizedBox(height: 20),
                                  _selectedTab == 0
                                      ? _buildBarcodeScannerPlaceholder()
                                      : const LiveCameraFeedCard(),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPreviewHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isWide ? 24.0 : 16.0,
            horizontal: isWide ? 32.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_android,
                      color: Colors.blueGrey, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tracit.ai Mobile Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black87,
                            fontSize: isWide ? 22 : 18,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildFeatureTag(context, 'Barcode Scanning'),
                  _buildFeatureTag(context, 'Object Detection'),
                  _buildFeatureTag(context, 'Firebase Sync'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureTag(BuildContext context, String text) {
    IconData? icon;
    switch (text) {
      case 'Barcode Scanning':
        icon = Icons.qr_code;
        break;
      case 'Object Detection':
        icon = Icons.visibility;
        break;
      case 'Firebase Sync':
        icon = Icons.cloud;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
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
        height: MediaQuery.of(context).size.height * 0.5,
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
