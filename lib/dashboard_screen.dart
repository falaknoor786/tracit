import 'package:flutter/material.dart';
import 'package:inventory_management_system/object_detection_screen.dart';
import 'package:inventory_management_system/product_screen.dart';
import 'package:inventory_management_system/sidebar.dart';
import 'package:inventory_management_system/subcategory_screen.dart';

import 'Settings_Screen.dart';
import 'Users.dart';
import 'category_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final screens = [
    Center(child: Text("📊 Welcome to the Admin Dashboard")),
    CategoryScreen(),
    SubcategoryScreen(),
    ProductScreen(),
    Users(),
    SettingsScreen(),
    ObjectDetectionScreen(),
  ];

  final titles = [
    "Dashboard",
    "Categories",
    "Subcategories",
    "Products",
    "Users",
    "Settings",
    "obj",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.deepPurple[50],
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    titles[selectedIndex],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: screens[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
