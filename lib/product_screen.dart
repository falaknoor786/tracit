import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? selectedCategoryId;
  String? selectedSubcategoryId;

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  Uint8List? fileBytes;
  String? fileName;

  bool isLoading = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  void addProduct() async {
    final name = nameController.text.trim();
    final description = descController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty ||
        description.isEmpty ||
        price == null ||
        selectedCategoryId == null ||
        selectedSubcategoryId == null ||
        fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and select an image."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final base64Image = base64Encode(fileBytes!);

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(selectedCategoryId)
        .collection('subcategories')
        .doc(selectedSubcategoryId)
        .collection('products')
        .add({
      'name': name,
      'description': description,
      'price': price,
      'imageBase64': base64Image,
      'createdAt': Timestamp.now(),
    });

    nameController.clear();
    descController.clear();
    priceController.clear();
    setState(() {
      fileBytes = null;
      fileName = null;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Product added successfully!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(selectedCategoryId)
        .collection('subcategories')
        .doc(selectedSubcategoryId)
        .collection('products')
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Management",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Product Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 16),

                      /// --- CATEGORY SELECT ---
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categories')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());
                          final docs = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: "Category",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            hint: Text("Select Category"),
                            items: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(data['name'],
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCategoryId = val;
                                selectedSubcategoryId = null;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: 16),

                      /// --- SUBCATEGORY SELECT ---
                      if (selectedCategoryId != null)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categories')
                              .doc(selectedCategoryId)
                              .collection('subcategories')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Center(child: CircularProgressIndicator());
                            final docs = snapshot.data!.docs;
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedSubcategoryId,
                              decoration: InputDecoration(
                                labelText: "Subcategory",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              hint: Text("Select Subcategory"),
                              items: docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: doc.id,
                                  child: Text(data['name'],
                                      overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedSubcategoryId = val;
                                });
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Add New Product",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 16),

                      /// --- ADD PRODUCT FORM ---
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixText: "\$ ",
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16),

                      // Image picker section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: pickImage,
                            icon:
                                Icon(Icons.image, color: Colors.blue.shade800),
                            label: Text(
                              "Select Product Image",
                              style: TextStyle(color: Colors.blue.shade800),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.blue.shade800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          if (fileBytes != null) ...[
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        fileBytes!,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      fileName ?? 'Selected image',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ],
                      ),
                      SizedBox(height: 16),

                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: addProduct,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  "Add Product",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (selectedCategoryId != null && selectedSubcategoryId != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Product List",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('categories')
                              .doc(selectedCategoryId)
                              .collection('subcategories')
                              .doc(selectedSubcategoryId)
                              .collection('products')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Center(child: CircularProgressIndicator());
                            final docs = snapshot.data!.docs;

                            if (docs.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  "No products found in this subcategory.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                return Dismissible(
                                  key: Key(docs[index].id),
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 20),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text(
                                            "Are you sure you want to delete this product?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) =>
                                      deleteProduct(docs[index].id),
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    leading: data['imageBase64'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.memory(
                                              base64Decode(data['imageBase64']),
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.image,
                                                color: Colors.grey),
                                          ),
                                    title: Text(
                                      data['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['description'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '\$${data['price'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        bool confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Confirm Delete"),
                                            content: Text(
                                                "Are you sure you want to delete this product?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: Text("Delete",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          deleteProduct(docs[index].id);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
