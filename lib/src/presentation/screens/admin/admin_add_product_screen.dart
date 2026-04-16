// lib/src/presentation/screens/admin/admin_add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/admin/admin_bloc.dart';
import '../../../utils/constants/app_constants.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});
  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  String _selectedCategory = AppConstants.categories.first;
  final List<File> _images = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked.map((x) => File(x.path))));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image'), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<AdminBloc>().add(AdminAddProduct(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_qtyCtrl.text),
      imageFiles: _images,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Add Product'),
      ),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminDashboardLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added!'), backgroundColor: Colors.green),
            );
            context.pop();
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images picker
                const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 90, height: 90,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.grey),
                              Text('Add', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      ..._images.map((f) => Stack(
                        children: [
                          Container(
                            width: 90, height: 90,
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(f, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 0, right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.remove(f)),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _field(_nameCtrl, 'Product Name', required: true),
                const SizedBox(height: 12),
                _field(_descCtrl, 'Description', maxLines: 3),
                const SizedBox(height: 12),
                _field(_priceCtrl, 'Price', type: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null),
                const SizedBox(height: 12),
                _field(_qtyCtrl, 'Quantity', type: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid quantity' : null),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AdminBloc, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add Product',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator ?? (v) => required && (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
