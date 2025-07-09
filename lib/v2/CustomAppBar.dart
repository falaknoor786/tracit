import 'package:flutter/material.dart';
import 'package:inventory_management_system/v2/Inv.dart';

import 'DashboardPage.dart';

// --- CUSTOM APP BAR WIDGET ---
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  // Define consistent colors from the main DashboardPage
  static const Color _primaryPurple = Color(0xFF4C2A9A); // Deep purple
  static const Color _mediumPurple = Color(0xFF8A2BE2); // Medium purple

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Standard app bar height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _primaryPurple, // Deep purple from the image
      elevation: 0, // No shadow for a flat design
      titleSpacing: 0, // Remove default title spacing

      title: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(Icons.flash_on,
                    color: Colors.white, size: 28), // Lightning bolt icon
                SizedBox(width: 8),
                Text(
                  'Tracit.ai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // Pushes elements to the right
          _buildAppBarButton(
            context: context,
            icon: Icons.flash_on, // Example icon, could be camera
            label: 'Live Scan',
            isPrimary: true,
            onPressed: () {
              // TODO: Navigate to Live Scan page (or set tab)
              print('Live Scan pressed from AppBar');
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.inventory,
            label: 'Inventory',
            onPressed: () {
              // Corrected: Navigate to Inventory page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Inv()),
              );
              print('Inventory pressed');
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.shopping_cart,
            label: 'Orders',
            onPressed: () {
              // Navigate to Placeholder page for Orders
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const PlaceholderPage(title: 'Orders')),
              );
              print('Orders pressed');
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.admin_panel_settings,
            label: 'Admin',
            onPressed: () {
              // Navigate to Placeholder page for Admin
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const PlaceholderPage(title: 'Admin Panel')),
              );
              print('Admin pressed');
            },
          ),
          const SizedBox(width: 20),
          _buildLoginSignupButton(
            context: context,
            onPressed: () {
              // TODO: Handle Login/Signup
              print('Login / Signup pressed');
            },
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white, // Or a specific color for the icon
              radius: 18,
              child: Icon(Icons.person, color: _primaryPurple, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets for CustomAppBar ---

  Widget _buildAppBarButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? _mediumPurple
            : Colors.transparent, // Purple background for primary
        borderRadius: BorderRadius.circular(25),
        border: isPrimary
            ? null
            : Border.all(color: Colors.transparent), // No border for primary
      ),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTextButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return MaterialButton(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSignupButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onPressed: onPressed,
        child: const Text(
          'Login / Signup',
          style: TextStyle(
            color: _primaryPurple, // Text color same as app bar background
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// --- PLACEHOLDER WIDGETS FOR DASHBOARD CONTENT ---
// These are added to make the DashboardPage code runnable without external files
class PointCalculatorCard extends StatelessWidget {
  const PointCalculatorCard({super.key});

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
            Text(
              'Point Calculator',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text('This is a placeholder for the Point Calculator.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Calculate Points pressed');
              },
              child: const Text('Calculate Points'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetectedItemsSection extends StatelessWidget {
  const DetectedItemsSection({super.key});

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
            Text(
              'Detected Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text('List of detected items will appear here.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('View All Items pressed');
              },
              child: const Text('View All Items'),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveCameraFeedCard extends StatelessWidget {
  const LiveCameraFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 500, // Adjust height as needed for the camera feed
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Live Camera Feed will appear here',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'This is a placeholder for the real-time object detection.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW INVENTORY PAGE ---
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom app bar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 80, color: Color(0xFF4C2A9A)),
            const SizedBox(height: 20),
            const Text(
              'Inventory Management',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C2A9A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'This page will display your current inventory items.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back to Dashboard'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8A2BE2), // Medium purple
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- GENERIC PLACEHOLDER PAGE ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom app bar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Orders'
                  ? Icons.shopping_cart
                  : Icons.admin_panel_settings,
              size: 80,
              color: const Color(0xFF4C2A9A),
            ),
            const SizedBox(height: 20),
            Text(
              '$title Screen (Under Construction)',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C2A9A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'This page is a placeholder for future content.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8A2BE2), // Medium purple
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MAIN APP WIDGET (for demonstration) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracit.ai Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardPage(), // Set DashboardPage as the home screen
    );
  }
}
