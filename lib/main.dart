import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:inventory_management_system/v2/DashboardPage.dart';
import 'package:inventory_management_system/v2/InventoryDashboardScreen.dart';

import 'LiveScannerPage.dart'; // Make sure this file exists with a widget named LiveScannerPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          // apiKey: "AIzaSyB54e7PAPaGQEmEwDxuuxHS09miTJNzjpM",
          // authDomain: "illmupdate.firebaseapp.com",
          // projectId: "illmupdate",
          // storageBucket: "illmupdate.appspot.com",
          // messagingSenderId: "1019083668709",
          // appId: "1:1019083668709:web:15bcb683c400bae466a80c",
          // measurementId: "G-3F8ZM6W72G",
          apiKey: "AIzaSyADI41t-ABSpet4t4SV45I2RtKqS4s4qWE",
          authDomain: "tracit-a57fc.firebaseapp.com",
          projectId: "tracit-a57fc",
          storageBucket: "tracit-a57fc.firebasestorage.app",
          messagingSenderId: "490678157751",
          appId: "1:490678157751:web:6f2f56c3d8459230596832",
          measurementId: "G-2Y99D9B5PV"),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(xMyApp());
}

class TracitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracit.ai',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          color: Colors.deepPurple,
          child: Row(
            children: [
              Spacer(),
              Text(
                'Tracit.ai',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              _buildNavItem(0, Icons.qr_code_scanner, 'Live Scan'),
              _buildNavItem(1, Icons.inventory_rounded, 'Inventory'),
              _buildNavItem(2, Icons.shopping_bag_rounded, 'Orders'),
              _buildNavItem(3, Icons.settings_rounded, 'Admin'),
              Spacer(),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ),
      ),
      body: _getSelectedPage(),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            color:
                _selectedIndex == index ? Colors.white : Colors.grey.shade400,
            onPressed: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  _selectedIndex == index ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return LiveCameraFeedCard();
      case 1:
        return InventoryPage();
      case 2:
        return OrdersPage();
      case 3:
        return AdminPage();
      default:
        return Center(child: Text("Page not found"));
    }
  }
}

// Placeholder pages (replace with your actual pages)
class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Inventory Page"));
  }
}

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Orders Page"));
  }
}

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Admin Page"));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Standard app bar height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4C2A9A), // Deep purple from the image
      elevation: 0, // No shadow for a flat design
      titleSpacing: 0, // Remove default title spacing

      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                const Icon(Icons.flash_on,
                    color: Colors.white, size: 28), // Lightning bolt icon
                const SizedBox(width: 8),
                InkWell(
                  child: const Text(
                    'Tracit.ai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  },
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
              // TODO: Navigate to Live Scan page

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ObjectDetectionScreen()),
              );
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.inventory,
            label: 'Inventory',
            onPressed: () {
              // TODO: Navigate to Inventory page
              print('Inventory pressed');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InventoryDashboardScreen()),
              );
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.shopping_cart,
            label: 'Orders',
            onPressed: () {
              // TODO: Navigate to Orders page
              print('Orders pressed');
            },
          ),
          const SizedBox(width: 20),
          _buildAppBarTextButton(
            context: context,
            icon: Icons.admin_panel_settings,
            label: 'Admin',
            onPressed: () {
              // TODO: Navigate to Admin page
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
              child: Icon(Icons.person, color: Colors.deepPurple, size: 24),
            ),
          ),
        ],
      ),
    );
  }

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
            ? const Color(0xFF8A2BE2)
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
            color: Color(0xFF4C2A9A), // Text color same as app bar background
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
