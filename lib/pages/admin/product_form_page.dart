import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../auth_service.dart';

class ProductFormPage extends StatefulWidget {
  final AuthService authService;
  final Map<String, dynamic>? product;

  const ProductFormPage({
    Key? key,
    required this.authService,
    this.product,
  }) : super(key: key);

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late AdminApiService _apiService;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  
  List<dynamic> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _apiService = AdminApiService(widget.authService);
    _loadCategories();
    
    if (_isEditing) {
      _populateFields();
    }
  }
  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product['name']?.toString() ?? '';
    _descriptionController.text = product['description']?.toString() ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _imageController.text = product['image']?.toString() ?? '';
    
    // Handle category_id safely
    if (product['category_id'] != null) {
      if (product['category_id'] is int) {
        _selectedCategoryId = product['category_id'];
      } else if (product['category_id'] is String) {
        _selectedCategoryId = int.tryParse(product['category_id']);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });    try {
      // Prepare product data with proper validation
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final priceText = _priceController.text.trim();
      final image = _imageController.text.trim();

      if (name.isEmpty) {
        throw Exception('Product name is required');
      }

      if (_selectedCategoryId == null) {
        throw Exception('Please select a category');
      }

      // Parse and validate price
      final price = double.tryParse(priceText);
      if (price == null || price < 0) {
        throw Exception('Please enter a valid price');
      }

      final productData = {
        'product_name': name,
        'product_description': description,
        'product_price': price,
        'product_image': image,
        'category_id': _selectedCategoryId,
      };

      print('Sending product data: $productData');

      bool success;
      if (_isEditing) {
        // Get product ID safely
        final productId = widget.product!['id'];
        int id;
        if (productId is int) {
          id = productId;
        } else if (productId is String) {
          id = int.tryParse(productId) ?? 0;
        } else {
          throw Exception('Invalid product ID');
        }
        
        if (id <= 0) {
          throw Exception('Invalid product ID for update');
        }
        
        success = await _apiService.updateProduct(id, productData);
      } else {
        success = await _apiService.createProduct(productData);
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product ${_isEditing ? 'updated' : 'created'} successfully')),
          );
        }
      } else {
        throw Exception('Failed to ${_isEditing ? 'update' : 'create'} product');
      }
    } catch (e) {
      print('Save product error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }    }finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
        title: Text(
          _isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.black),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map<DropdownMenuItem<int>>((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(236, 170, 27, 1.0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              _isEditing ? 'Update Product' : 'Create Product',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}