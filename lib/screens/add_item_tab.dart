import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../repositories/vendor_repository.dart';

class AddItemTab extends StatefulWidget {
  const AddItemTab({super.key});

  @override
  State<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends State<AddItemTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _previewUrl; // 👈 holds the current preview URL if valid

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    setState(() => _previewUrl = null); // reset preview
  }

  @override
  void initState() {
    super.initState();

    // 👇 Listen to changes in the image URL field
    _imageUrlController.addListener(() {
      final text = _imageUrlController.text.trim();

      // Relaxed validation: just check http/https
      if (text.isNotEmpty &&
          (text.startsWith('http://') || text.startsWith('https://'))) {
        setState(() => _previewUrl = text);
      } else {
        setState(() => _previewUrl = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Read the concrete type, then upcast to the abstraction
    final repo = Provider.of<InMemoryVendorRepository>(context, listen: false);
    final VendorRepository vendorRepo = repo;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // ----------------------------
            // Name field
            // ----------------------------
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a name' : null,
            ),

            // ----------------------------
            // Description field
            // ----------------------------
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            // ----------------------------
            // Price field (with validation)
            // ----------------------------
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a price';
                }
                final parsed = double.tryParse(value);
                if (parsed == null) {
                  return 'Enter a valid number';
                }
                if (parsed < 0) {
                  return 'Price cannot be negative';
                }
                // 👇 Zero is allowed (giveaways), positive numbers are fine too
                return null;
              },
            ),

            // ----------------------------
            // Image URL field
            // ----------------------------
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),

            // ----------------------------
            // Live image preview (or placeholder)
            // ----------------------------
            const SizedBox(height: 12),
            Text('Preview:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: _previewUrl != null
                  ? Image.network(
                      _previewUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Could not load image. Please check the URL.',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    )
                  : const Text(
                      'No preview available',
                      style: TextStyle(color: Colors.grey),
                    ),
            ),

            const SizedBox(height: 20),

            // ----------------------------
            // Submit button
            // ----------------------------
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newItem = Item(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    price: double.parse(_priceController.text), // safe now
                    imageUrl: _imageUrlController.text.trim(),
                  );

                  // Add to repository (this triggers notifyListeners)
                  vendorRepo.addItem(newItem);

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${newItem.name} added!')),
                  );

                  // Reset form fields
                  _clearForm();
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}