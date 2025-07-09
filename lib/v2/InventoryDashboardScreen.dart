import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryItem {
  final String id;
  final String name;
  final String? image;
  final Timestamp createdAt;
  final String? category;
  final int? points;
  final int? stock;

  InventoryItem({
    required this.id,
    required this.name,
    this.image,
    required this.createdAt,
    this.category,
    this.points,
    this.stock,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      image: data['image'] as String?,
      createdAt: data['created_at'] as Timestamp? ?? Timestamp.now(),
      category: data['category'] as String?,
      points: data['points'] as int?,
      stock: data['stock'] as int?,
    );
  }
}

class InventoryDashboardScreen extends StatefulWidget {
  @override
  _InventoryDashboardScreenState createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMobileLayout = false;

  @override
  void initState() {
    super.initState();
    _fetchInventoryData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkScreenSize();
  }

  void _checkScreenSize() {
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      _isMobileLayout = mediaQuery.size.width < 800;
    });
  }

  Future<void> _fetchInventoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('inventory').get();

      _inventoryItems = querySnapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();

      _inventoryItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Error fetching inventory data: $e");
      _errorMessage = "Failed to load inventory. Please try again.";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Tracit.ai',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Spacer(),
            _buildAppBarNavLink(Icons.sensors, 'Live Scan', true),
            SizedBox(width: 32),
            _buildAppBarNavLink(Icons.inventory, 'Inventory', false),
            SizedBox(width: 32),
            _buildAppBarNavLink(Icons.list_alt, 'Orders', false),
            SizedBox(width: 32),
            _buildAppBarNavLink(Icons.admin_panel_settings, 'Admin', false),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 8),
                  Text('Login / Signup', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.flash_on, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text('Tracit.ai'),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(_inventoryItems),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          _buildDrawerItem(Icons.sensors, 'Live Scan', true),
          _buildDrawerItem(Icons.inventory, 'Inventory', false),
          _buildDrawerItem(Icons.list_alt, 'Orders', false),
          _buildDrawerItem(Icons.admin_panel_settings, 'Admin', false),
          Divider(),
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Login / Signup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive) {
    return ListTile(
      leading:
          Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.deepPurple : Colors.grey[600],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildAppBarNavLink(IconData icon, String text, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon,
              color: isActive ? Colors.deepPurple : Colors.grey[600], size: 20),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.deepPurple : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchInventoryData,
                      child: Text("Retry"),
                    ),
                  ],
                ),
              )
            : _isMobileLayout
                ? _buildMobileLayout()
                : _buildDesktopLayout();
  }

  Widget _buildDesktopLayout() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewSection(),
                SizedBox(height: 24),
                _buildInventoryManagementSection(),
              ],
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopMovers(),
                SizedBox(height: 24),
                _buildSlowestMovers(),
                SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewSection(),
          SizedBox(height: 24),
          _buildQuickActions(),
          SizedBox(height: 24),
          _buildInventoryManagementSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    int totalItems = _inventoryItems.length;
    int lowStockItems =
        _inventoryItems.where((item) => (item.stock ?? 0) < 5).length;
    int todaysRedemptions = 0;
    int pointsRedeemed = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 16),
        _isMobileLayout
            ? Column(
                children: [
                  _buildOverviewCard('Total Items', totalItems.toString(),
                      Colors.deepPurple, Colors.deepPurple[100]!),
                  SizedBox(height: 12),
                  _buildOverviewCard('Low Stock', lowStockItems.toString(),
                      Colors.orange, Colors.orange[100]!),
                  SizedBox(height: 12),
                  _buildOverviewCard(
                      'Today\'s Redemptions',
                      todaysRedemptions.toString(),
                      Colors.green,
                      Colors.green[100]!),
                  SizedBox(height: 12),
                  _buildOverviewCard(
                      'Points Redeemed',
                      pointsRedeemed.toString(),
                      Colors.deepPurple,
                      Colors.deepPurple[100]!),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                        'Total Items',
                        totalItems.toString(),
                        Colors.deepPurple,
                        Colors.deepPurple[100]!),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                        'Low Stock',
                        lowStockItems.toString(),
                        Colors.orange,
                        Colors.orange[100]!),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                        'Today\'s Redemptions',
                        todaysRedemptions.toString(),
                        Colors.green,
                        Colors.green[100]!),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                        'Points Redeemed',
                        pointsRedeemed.toString(),
                        Colors.deepPurple,
                        Colors.deepPurple[100]!),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, Color color, Color bgColor) {
    return Container(
      margin: _isMobileLayout ? EdgeInsets.zero : EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: _isMobileLayout ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inventory',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            if (!_isMobileLayout) ...[
              Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Categories',
                    items: <String>[
                      'All Categories',
                      'Toys',
                      'Accessories',
                      'Collectibles'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {},
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_isMobileLayout) ...[
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: 'All Categories',
                items: <String>[
                  'All Categories',
                  'Toys',
                  'Accessories',
                  'Collectibles'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
            ),
          ),
        ],
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: _isMobileLayout
              ? _buildMobileInventoryList()
              : _buildDesktopInventoryTable(),
        ),
      ],
    );
  }

  Widget _buildDesktopInventoryTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('ITEM',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))),
              Expanded(
                  flex: 2,
                  child: Text('CATEGORY',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))),
              Expanded(
                  flex: 1,
                  child: Text('POINTS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))),
              Expanded(
                  flex: 1,
                  child: Text('STOCK',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))),
              Expanded(
                  flex: 1,
                  child: Text('7D TREND',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[200]),
        if (_inventoryItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('No inventory items found.',
                style: TextStyle(color: Colors.grey[500])),
          )
        else
          ..._inventoryItems.map((item) {
            ImageProvider? itemImage;
            if (item.image != null && item.image!.isNotEmpty) {
              try {
                itemImage = MemoryImage(base64Decode(item.image!));
              } catch (e) {
                print("Error decoding image for ${item.name}: $e");
                itemImage = null;
              }
            }

            bool? trendUp;
            int trendValue = 0;
            if ((item.stock ?? 0) > 10) {
              trendUp = true;
              trendValue = (item.stock ?? 0) ~/ 5;
            } else if ((item.stock ?? 0) < 5) {
              trendUp = false;
              trendValue = (item.stock ?? 0);
            }

            return _buildInventoryRow(
              itemName: item.name,
              itemDescription:
                  'Added on ${item.createdAt.toDate().toLocal().toString().split(' ')[0]}',
              category: item.category ?? 'Uncategorized',
              points: (item.points ?? 0).toString(),
              stock: (item.stock ?? 0).toString() + ' units',
              trendUp: trendUp,
              trendValue: trendValue,
              itemImage: itemImage,
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMobileInventoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _inventoryItems.isEmpty ? 1 : _inventoryItems.length,
      itemBuilder: (context, index) {
        if (_inventoryItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('No inventory items found.',
                style: TextStyle(color: Colors.grey[500])),
          );
        }

        final item = _inventoryItems[index];
        ImageProvider? itemImage;
        if (item.image != null && item.image!.isNotEmpty) {
          try {
            itemImage = MemoryImage(base64Decode(item.image!));
          } catch (e) {
            print("Error decoding image for ${item.name}: $e");
            itemImage = null;
          }
        }

        bool? trendUp;
        int trendValue = 0;
        if ((item.stock ?? 0) > 10) {
          trendUp = true;
          trendValue = (item.stock ?? 0) ~/ 5;
        } else if ((item.stock ?? 0) < 5) {
          trendUp = false;
          trendValue = (item.stock ?? 0);
        }

        return _buildMobileInventoryItem(
          itemName: item.name,
          itemDescription:
              'Added on ${item.createdAt.toDate().toLocal().toString().split(' ')[0]}',
          category: item.category ?? 'Uncategorized',
          points: (item.points ?? 0).toString(),
          stock: (item.stock ?? 0).toString() + ' units',
          trendUp: trendUp,
          trendValue: trendValue,
          itemImage: itemImage,
        );
      },
    );
  }

  Widget _buildInventoryRow({
    required String itemName,
    required String itemDescription,
    required String category,
    required String points,
    required String stock,
    bool? trendUp,
    required int trendValue,
    ImageProvider? itemImage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: itemImage != null
                      ? Image(
                          image: itemImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image,
                                size: 20, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: Icon(Icons.inventory,
                              size: 20, color: Colors.grey[400]),
                        ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemName,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(itemDescription,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(category,
                  style: TextStyle(color: Colors.blue[700], fontSize: 12)),
            ),
          ),
          Expanded(flex: 1, child: Text(points)),
          Expanded(flex: 1, child: Text(stock)),
          Expanded(
            flex: 1,
            child: trendUp == null
                ? Text('- 0')
                : Row(
                    children: [
                      Icon(
                        trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        color: trendUp ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        ' ${trendUp ? '+' : '-'}$trendValue',
                        style: TextStyle(
                            color: trendUp ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInventoryItem({
    required String itemName,
    required String itemDescription,
    required String category,
    required String points,
    required String stock,
    bool? trendUp,
    required int trendValue,
    ImageProvider? itemImage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: itemImage != null
                    ? Image(
                        image: itemImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image,
                              size: 24, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: Icon(Icons.inventory,
                            size: 24, color: Colors.grey[400]),
                      ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(itemDescription,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(category,
                    style: TextStyle(color: Colors.blue[700], fontSize: 12)),
              ),
              Spacer(),
              Text('$points pts',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Text(stock, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 8),
          trendUp == null
              ? Text('- 0', style: TextStyle(color: Colors.grey[500]))
              : Row(
                  children: [
                    Icon(
                      trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                      color: trendUp ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    Text(
                      ' ${trendUp ? '+' : '-'}$trendValue',
                      style:
                          TextStyle(color: trendUp ? Colors.green : Colors.red),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTopMovers() {
    return _buildSidePanelCard(
      'Top Movers (7d)',
      Column(
        children: [
          SizedBox(height: 16),
          Text(
            'No trend data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSlowestMovers() {
    return _buildSidePanelCard(
      'Slowest Movers (7d)',
      Column(
        children: [
          SizedBox(height: 16),
          Text(
            'No trend data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildSidePanelCard(
      'Quick Actions',
      Column(
        children: [
          SizedBox(height: 16),
          _buildQuickActionButton(
            'Add New Item',
            Icons.add,
            Colors.deepPurple,
          ),
          SizedBox(height: 12),
          _buildQuickActionButton(
            'Export Report',
            Icons.download,
            Colors.deepPurple,
          ),
          SizedBox(height: 12),
          _buildQuickActionButton(
            'Sync Inventory',
            Icons.sync,
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanelCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      margin: _isMobileLayout ? EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          print('$text button pressed!');
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<InventoryItem> inventoryItems;

  CustomSearchDelegate(this.inventoryItems);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = inventoryItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('Stock: ${item.stock ?? 0}'),
          onTap: () {
            close(context, item);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = inventoryItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('Stock: ${item.stock ?? 0}'),
          onTap: () {
            query = item.name;
            showResults(context);
          },
        );
      },
    );
  }
}
