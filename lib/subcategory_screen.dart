import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubcategoryScreen extends StatefulWidget {
  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final _subcategoryController = TextEditingController();
  String? _selectedCategoryId;

  void addSubcategory() async {
    final name = _subcategoryController.text.trim();
    if (name.isEmpty || _selectedCategoryId == null) return;

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(_selectedCategoryId)
        .collection('subcategories')
        .add({
      'name': name,
      'createdAt': Timestamp.now(),
    });

    _subcategoryController.clear();
  }

  void deleteSubcategory(String subId) async {
    if (_selectedCategoryId == null) return;

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(_selectedCategoryId)
        .collection('subcategories')
        .doc(subId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Category",
              style: Theme.of(context).textTheme.titleLarge),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              final docs = snapshot.data!.docs;

              return DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategoryId,
                hint: Text("Choose category"),
                items: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryId = val;
                  });
                },
              );
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: _subcategoryController,
            decoration: InputDecoration(
              labelText: "Subcategory Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: addSubcategory,
            child: Text("Add Subcategory"),
          ),
          SizedBox(height: 20),
          Text("Subcategories", style: Theme.of(context).textTheme.titleLarge),
          Expanded(
            child: _selectedCategoryId == null
                ? Center(child: Text("Please select a category"))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .doc(_selectedCategoryId)
                        .collection('subcategories')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;

                          return Card(
                            child: ListTile(
                              title: Text(data['name']),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteSubcategory(docId),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
