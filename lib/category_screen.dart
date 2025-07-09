import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _categoryController = TextEditingController();

  void addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    await FirebaseFirestore.instance.collection('categories').add({
      'name': name,
      'createdAt': Timestamp.now(),
    });

    _categoryController.clear();
  }

  void deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection('categories').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add Category", style: Theme.of(context).textTheme.titleLarge),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: "Enter category name",
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: addCategory,
                child: Text("Add"),
              ),
            ],
          ),
          SizedBox(height: 30),
          Text("Existing Categories",
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card(
                      child: ListTile(
                        title: Text(data['name']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteCategory(docId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
