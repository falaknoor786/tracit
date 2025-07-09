import 'package:flutter/material.dart';

// Model class (adjust based on your actual item structure)
class DetectedItem {
  final String name;
  final int quantity;

  DetectedItem({required this.name, required this.quantity});
}

class DetectedItemsSection extends StatelessWidget {
  final List<DetectedItem> items;

  const DetectedItemsSection({super.key, required this.items});

  static const Color _primaryPurple = Color(0xFF4C2A9A);

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
            Row(
              children: [
                const Icon(Icons.track_changes,
                    color: _primaryPurple, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Detected Items',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1, color: Colors.grey),

            // Show item list or empty state
            items.isEmpty
                ? Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.checklist,
                            size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'No items detected yet.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          'Scan or upload an image to see results.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.check_box, color: _primaryPurple),
                        title: Text(item.name),
                        trailing: Text('x ${item.quantity}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
