import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_app/models/menu_item.dart';
import 'package:restaurant_app/services/menu_management_service.dart';

class MenuManagementWidget extends StatefulWidget {
  const MenuManagementWidget({super.key});

  @override
  State<MenuManagementWidget> createState() => _MenuManagementWidgetState();
}

class _MenuManagementWidgetState extends State<MenuManagementWidget> {
  final MenuManagementService _menuService = MenuManagementService();

  final List<String> _categories = [
    'Starters',
    'Main Course', // Changed from 'Main Courses' to 'Main Course'
    'Desserts',
    'Beverages',
    'Sides',
    'Salads',
    'Soups',
    'Breads',
    'Specials'
  ];

  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isVegetarian = false;
  bool _isSpicy = false;
  String _sortBy = 'name';

  // Bulk operations
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};
  bool _isExporting = false;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedItemIds.length} items selected')
            : const Text('Menu Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditMenuItemDialog(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => setState(() => _sortBy = value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                const PopupMenuItem(
                    value: 'price', child: Text('Sort by Price')),
                const PopupMenuItem(
                    value: 'category', child: Text('Sort by Category')),
              ],
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              tooltip:
                  _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () => _toggleSelectionMode(),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _clearSelection(),
            ),
            PopupMenuButton<String>(
              onSelected: _handleBulkAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'outOfStock', child: Text('Mark Out of Stock')),
                const PopupMenuItem(
                    value: 'inStock', child: Text('Mark In Stock')),
                const PopupMenuItem(
                    value: 'markRecommended',
                    child: Text('Mark as Recommended')),
                const PopupMenuItem(
                    value: 'unmarkRecommended',
                    child: Text('Remove from Recommended')),
                const PopupMenuItem(
                    value: 'markOffer', child: Text('Mark as Offer')),
                const PopupMenuItem(
                    value: 'unmarkOffer', child: Text('Remove from Offers')),
                const PopupMenuItem(
                    value: 'export', child: Text('Export Selected')),
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete Selected')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildFiltersHeader(),
          Expanded(child: _buildMenuItemsList()),
        ],
      ),
    );
  }

  Widget _buildFiltersHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['all', ..._categories]
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                              category == 'all' ? 'All Categories' : category),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('Vegetarian'),
                selected: _isVegetarian,
                onSelected: (selected) =>
                    setState(() => _isVegetarian = selected),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Spicy'),
                selected: _isSpicy,
                onSelected: (selected) => setState(() => _isSpicy = selected),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: StreamBuilder<List<MenuItem>>(
        stream: _menuService.getMenuItems(
          category: _selectedCategory == 'all' ? null : _selectedCategory,
          isVegetarian: _isVegetarian ? true : null,
          isSpicy: _isSpicy ? true : null,
          sortBy: _sortBy,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No menu items found'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditMenuItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add first menu item'),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!
              .where((item) =>
                  item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          if (items.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No items found for "$_searchQuery"'),
                ],
              ),
            );
          }

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMenuItemCard(item);
              },
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildMenuItemListTile(item);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (_isSelectionMode) {
            _toggleItemSelection(item.id);
          } else {
            _showAddEditMenuItemDialog(existingItem: item);
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            _toggleSelectionMode();
            _toggleItemSelection(item.id);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isSelectionMode)
              CheckboxListTile(
                title: const Text('Select'),
                value: _selectedItemIds.contains(item.id),
                onChanged: (selected) => _toggleItemSelection(item.id),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.fastfood, size: 48),
                      )
                    : const Center(child: Icon(Icons.fastfood, size: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.isVegetarian)
                            const Icon(Icons.eco,
                                size: 16, color: Colors.green),
                          if (item.isSpicy)
                            const Icon(Icons.local_fire_department,
                                size: 16, color: Colors.red),
                          if (item.isRecommended)
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                          if (item.hasOffer)
                            const Icon(Icons.local_offer,
                                size: 16, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemListTile(MenuItem item) {
    final isSelected = _selectedItemIds.contains(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: _isSelectionMode
              ? (selected) => _toggleItemSelection(item.id)
              : null,
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.category} • A\$${item.price.toStringAsFixed(2)}'),
            if (item.description.isNotEmpty)
              Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                if (item.isVegetarian)
                  const Icon(Icons.eco, size: 16, color: Colors.green),
                if (item.isSpicy)
                  const Icon(Icons.local_fire_department,
                      size: 16, color: Colors.red),
                if (item.isRecommended)
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                if (item.hasOffer)
                  const Icon(Icons.local_offer, size: 16, color: Colors.blue),
                if (!item.inStock)
                  const Text('Out of Stock',
                      style: TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditMenuItemDialog(existingItem: item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMenuItem(item.id),
            ),
          ],
        ),
        onTap: _isSelectionMode
            ? () => _toggleItemSelection(item.id)
            : () => _showAddEditMenuItemDialog(existingItem: item),
        onLongPress: () {
          if (!_isSelectionMode) {
            _toggleSelectionMode();
            _toggleItemSelection(item.id);
          }
        },
      ),
    );
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }

      if (_selectedItemIds.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItemIds.clear();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
  }

  void _showAddEditMenuItemDialog({MenuItem? existingItem}) {
    final isEditing = existingItem != null;
    final nameController =
        TextEditingController(text: existingItem?.name ?? '');
    final descriptionController =
        TextEditingController(text: existingItem?.description ?? '');
    final priceController =
        TextEditingController(text: existingItem?.price.toString() ?? '');
    final imageUrlController =
        TextEditingController(text: existingItem?.imageUrl ?? '');

    String category = existingItem?.category ?? _categories.first;
    bool isVegetarian = existingItem?.isVegetarian ?? false;
    bool isSpicy = existingItem?.isSpicy ?? false;
    bool isRecommended = existingItem?.isRecommended ?? false;
    bool inStock = existingItem?.inStock ?? true;
    bool hasOffer = existingItem?.hasOffer ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => category = value!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                CheckboxListTile(
                  title: const Text('Vegetarian'),
                  value: isVegetarian,
                  onChanged: (value) => setState(() => isVegetarian = value!),
                ),
                CheckboxListTile(
                  title: const Text('Spicy'),
                  value: isSpicy,
                  onChanged: (value) => setState(() => isSpicy = value!),
                ),
                CheckboxListTile(
                  title: const Text('Recommended'),
                  value: isRecommended,
                  onChanged: (value) => setState(() => isRecommended = value!),
                ),
                CheckboxListTile(
                  title: const Text('In Stock'),
                  value: inStock,
                  onChanged: (value) => setState(() => inStock = value!),
                ),
                CheckboxListTile(
                  title: const Text('Has Offer'),
                  value: hasOffer,
                  onChanged: (value) => setState(() => hasOffer = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newItem = MenuItem(
                    id: isEditing ? existingItem.id : '',
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageUrlController.text,
                    category: category,
                    isVegetarian: isVegetarian,
                    isSpicy: isSpicy,
                    isRecommended: isRecommended,
                    inStock: inStock,
                    hasOffer: hasOffer,
                  );

                  if (isEditing) {
                    await _menuService.updateMenuItem(newItem);
                  } else {
                    await _menuService.createMenuItem(newItem);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(isEditing
                              ? 'Menu item updated'
                              : 'Menu item added')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        action: SnackBarAction(
                          label: 'Retry',
                          onPressed: () {
                            _showAddEditMenuItemDialog(
                                existingItem: existingItem);
                          },
                        ),
                      ),
                    );
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   onPressed: () {
                    //       _showAddEditMenuItemDialog(existingItem: existingItem);
                    //       onLongPress:() =>
                    //         _showAddEditMenuItemDialog(existingItem: existingItem);
                    //   SnackBar(content: Text('Error: ${e.toString()}'));
                    //   });
                  }
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMenuItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: const Text('Are you sure you want to delete this menu item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _menuService.deleteMenuItem(itemId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu item deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleBulkAction(String action) async {
    if (_selectedItemIds.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final itemId in _selectedItemIds) {
        final docRef =
            FirebaseFirestore.instance.collection('menuItems').doc(itemId);

        switch (action) {
          case 'outOfStock':
            batch.update(docRef, {'inStock': false});
            break;
          case 'inStock':
            batch.update(docRef, {'inStock': true});
            break;
          case 'markRecommended':
            batch.update(docRef, {'isRecommended': true});
            break;
          case 'unmarkRecommended':
            batch.update(docRef, {'isRecommended': false});
            break;
          case 'markOffer':
            batch.update(docRef, {'hasOffer': true});
            break;
          case 'unmarkOffer':
            batch.update(docRef, {'hasOffer': false});
            break;
        }
      }

      if (action == 'export') {
        await _exportSelected();
        return;
      }

      if (action == 'delete') {
        _deleteSelected();
        return;
      }

      await batch.commit();

      if (context.mounted) {
        String message = '';
        switch (action) {
          case 'outOfStock':
            message = 'Marked ${_selectedItemIds.length} items as out of stock';
            break;
          case 'inStock':
            message = 'Marked ${_selectedItemIds.length} items as in stock';
            break;
          case 'markRecommended':
            message = 'Marked ${_selectedItemIds.length} items as recommended';
            break;
          case 'unmarkRecommended':
            message =
                'Removed ${_selectedItemIds.length} items from recommended';
            break;
          case 'markOffer':
            message = 'Marked ${_selectedItemIds.length} items as offer';
            break;
          case 'unmarkOffer':
            message = 'Removed ${_selectedItemIds.length} items from offers';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _clearSelection();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportSelected() async {
    setState(() => _isExporting = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('menuItems')
          .where(FieldPath.documentId, whereIn: _selectedItemIds.toList())
          .get();

      final items =
          snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();

      final csvData = _generateCSV(items);
      _downloadCSV(
          csvData, 'menu_items_${DateTime.now().millisecondsSinceEpoch}.csv');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported ${items.length} items')),
        );
        _clearSelection();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _generateCSV(List<MenuItem> items) {
    final headers = [
      'ID',
      'Name',
      'Description',
      'Price',
      'Category',
      'Vegetarian',
      'Spicy',
      'Image URL'
    ];
    final rows = items.map((item) => [
          item.id,
          '"${item.name}"',
          '"${item.description}"',
          item.price.toStringAsFixed(2),
          item.category,
          item.isVegetarian.toString(),
          item.isSpicy.toString(),
          item.imageUrl,
        ]);

    return [headers, ...rows].map((row) => row.join(',')).join('\n');
  }

  void _downloadCSV(String csvData, String filename) {
    final blob = Uri.dataFromString(csvData, mimeType: 'text/csv');
    debugPrint('CSV data ready for download: ${csvData.substring(0, 100)}...');
  }

  void _deleteSelected() {
    if (_selectedItemIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Items'),
        content: Text(
            'Are you sure you want to delete ${_selectedItemIds.length} menu items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBulkDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBulkDelete() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final itemId in _selectedItemIds) {
        final docRef =
            FirebaseFirestore.instance.collection('menuItems').doc(itemId);
        batch.delete(docRef);
      }

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${_selectedItemIds.length} items')),
        );
        _clearSelection();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete error: ${e.toString()}')),
        );
      }
    }
  }
}
