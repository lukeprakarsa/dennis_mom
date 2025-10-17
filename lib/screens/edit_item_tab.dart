import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/vendor_repository.dart';
import '../widgets/item_thumbnail.dart';

class EditItemTab extends StatelessWidget {
  const EditItemTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Wrap in Consumer so it rebuilds when vendorRepo changes
    return Consumer<InMemoryVendorRepository>(
      builder: (context, repo, child) {
        // Upcast to the abstraction
        final VendorRepository vendorRepo = repo;

        final items = vendorRepo.getAllItems();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              // ----------------------------
              // Leading image with transparent fallback
              // ----------------------------
              leading: ItemThumbnail(
                imageUrl: item.imageUrl,
                width: 50,
                height: 50,
              ),
              title: Text(item.name),
              subtitle: Text(
                '${item.description}\n\$${item.price.toStringAsFixed(2)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ----------------------------
                  // Edit button
                  // ----------------------------
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final nameController =
                          TextEditingController(text: item.name);
                      final priceController =
                          TextEditingController(text: item.price.toString());
                      final descriptionController =
                          TextEditingController(text: item.description);
                      final imageUrlController =
                          TextEditingController(text: item.imageUrl);
                      final stockController =
                          TextEditingController(text: item.stock.toString()); // 👈 new controller

                      // 👇 Local state for preview inside the dialog
                      String previewUrl = item.imageUrl;

                      final formKey = GlobalKey<FormState>();

                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              title: const Text('Edit Item'),
                              content: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                            labelText: 'Name'),
                                        validator: (value) => value == null ||
                                                value.isEmpty
                                            ? 'Enter a name'
                                            : null,
                                      ),
                                      TextFormField(
                                        controller: priceController,
                                        decoration: const InputDecoration(
                                            labelText: 'Price'),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Enter a price';
                                          }
                                          final parsed =
                                              double.tryParse(value);
                                          if (parsed == null) {
                                            return 'Enter a valid number';
                                          }
                                          if (parsed < 0) {
                                            return 'Price cannot be negative';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: stockController,
                                        decoration: const InputDecoration(
                                            labelText: 'Stock Quantity'),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Enter stock quantity';
                                          }
                                          final parsed = int.tryParse(value);
                                          if (parsed == null || parsed < 0) {
                                            return 'Enter a non-negative whole number';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                            labelText: 'Description'),
                                      ),
                                      TextFormField(
                                        controller: imageUrlController,
                                        decoration: const InputDecoration(
                                            labelText: 'Image URL'),
                                        onChanged: (val) {
                                          if (val.startsWith('http')) {
                                            setState(() => previewUrl = val);
                                          } else {
                                            setState(() => previewUrl = '');
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Preview:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: previewUrl.isNotEmpty
                                            ? Image.network(
                                                previewUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Text(
                                                    'Could not load image.',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  );
                                                },
                                              )
                                            : const Text(
                                                'No preview available',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context), // Cancel
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      final updated = item.copyWith(
                                        name: nameController.text,
                                        price: double.parse(
                                            priceController.text),
                                        description:
                                            descriptionController.text,
                                        imageUrl:
                                            imageUrlController.text.trim(),
                                        stock: int.parse(
                                            stockController.text), // 👈 update stock
                                      );
                                      vendorRepo.editItem(item.id, updated);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // ----------------------------
                  // Delete button
                  // ----------------------------
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Item'),
                          content: Text(
                            'Are you sure you want to delete "${item.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                vendorRepo.deleteItem(item.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} deleted'),
                                  ),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}