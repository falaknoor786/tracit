import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:inventory_management_system/v2/DashboardPage.dart';
import 'package:inventory_management_system/v2/InventoryDashboardScreen.dart';

import 'LiveScannerPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADI41t-ABSpet4t4SV45I2RtKqS4s4qWE",
        authDomain: "tracit-a57fc.firebaseapp.com",
        projectId: "tracit-a57fc",
        storageBucket: "tracit-a57fc.firebasestorage.app",
        messagingSenderId: "490678157751",
        appId: "1:490678157751:web:6f2f56c3d8459230596832",
        measurementId: "G-2Y99D9B5PV",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(TracitApp());
}

class TracitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracit.ai',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.deepPurple,
      ),
      // home: MainScreen(),
      home: DashboardPage(),
      //  home: ObjectDetectionApp(),
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

  final List<Widget> pages = [
    LiveCameraFeedCard(),
    InventoryDashboardScreen(),
    OrdersPage(),
    AdminPage(),
  ];

  final List<String> titles = ["Live Scan", "Inventory", "Orders", "Admin"];
  final List<IconData> icons = [
    Icons.qr_code_scanner,
    Icons.inventory,
    Icons.shopping_cart,
    Icons.admin_panel_settings,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildWebNavBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      toolbarHeight: 70,
      title: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.white),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
            child: const Text(
              'Tracit.ai',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          for (int i = 0; i < titles.length; i++)
            _buildNavItem(i, icons[i], titles[i]),
          const SizedBox(width: 20),
          _buildLoginSignupButton(),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.person, color: Colors.deepPurple, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return MaterialButton(
      minWidth: 0,
      onPressed: () => _onItemTapped(index),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSignupButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onPressed: () {
          // Handle login/signup
        },
        child: const Text(
          'Login / Signup',
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon,
          color:
              _selectedIndex == index ? Colors.deepPurple : Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.deepPurple : Colors.grey[700],
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        Navigator.of(context).pop();
        _onItemTapped(index);
      },
    );
  }

  Widget _buildMobileBottomNavBar() {
    return BottomNavigationBar(
      items: [
        for (int i = 0; i < titles.length; i++)
          BottomNavigationBarItem(
            icon: Icon(icons[i]),
            label: titles[i],
          ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.deepPurple,
                  title: const Text(
                    'Tracit.ai',
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                )
              : PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: _buildWebNavBar(),
                ),
          drawer: isMobile
              ? Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.flash_on, color: Colors.white, size: 40),
                            SizedBox(height: 10),
                            Text(
                              'Tracit.ai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (int i = 0; i < titles.length; i++)
                        _buildDrawerItem(i, icons[i], titles[i]),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Login / Signup'),
                        onTap: () {
                          // Handle login/signup
                        },
                      ),
                    ],
                  ),
                )
              : null,
          body: pages[_selectedIndex],
          bottomNavigationBar: isMobile ? _buildMobileBottomNavBar() : null,
        );
      },
    );
  }
}

// Placeholder pages (replace with your actual pages)
class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Orders Page"));
  }
}

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Admin Page"));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppBar(
      backgroundColor: const Color(0xFF4C2A9A),
      elevation: 0,
      titleSpacing: 0,
      title: isMobile
          ? Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Tracit.ai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ],
            )
          : Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 28),
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
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _buildAppBarButton(
                  context: context,
                  icon: Icons.flash_on,
                  label: 'Live Scan',
                  isPrimary: true,
                  onPressed: () {
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
                    print('Orders pressed');
                  },
                ),
                const SizedBox(width: 20),
                _buildAppBarTextButton(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  label: 'Admin',
                  onPressed: () {
                    print('Admin pressed');
                  },
                ),
                const SizedBox(width: 20),
                _buildLoginSignupButton(
                  context: context,
                  onPressed: () {
                    print('Login / Signup pressed');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child:
                        Icon(Icons.person, color: Colors.deepPurple, size: 24),
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
        color: isPrimary ? const Color(0xFF8A2BE2) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: isPrimary ? null : Border.all(color: Colors.transparent),
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
            color: Color(0xFF4C2A9A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
