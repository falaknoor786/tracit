import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {"icon": Icons.dashboard, "label": "Dashboard"},
      {"icon": Icons.category, "label": "Categories"},
      {"icon": Icons.subtitles, "label": "Subcategories"},
      {"icon": Icons.shopping_cart, "label": "Products"},
      {"icon": Icons.people, "label": "Users"},
      {"icon": Icons.settings, "label": "Settings"},
      {"icon": Icons.data_object, "label": "Obj"},
    ];

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings,
                    size: 28, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Text(
                  "Admin Panel",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Menu items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return Material(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            menuItems[index]['icon'] as IconData,
                            size: 22,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            menuItems[index]['label'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer with user info
          const Divider(height: 1, thickness: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default_avatar.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin User",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      "admin@example.com",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
