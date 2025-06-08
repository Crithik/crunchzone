import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth_service.dart';

class AdminApiService {
  static const String baseUrl = 'http://13.201.189.84/api';
  final AuthService authService;

  AdminApiService(this.authService);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${authService.authToken}',
  };
  // Product CRUD Operations
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products'),
        headers: _headers,
      );
      
      print('Products API Response Status: ${response.statusCode}');
      print('Products API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle different response structures
        if (data is List) {
          return data;
        } else if (data is Map) {
          return data['data'] ?? data['products'] ?? [];
        }
        return [];
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Error fetching products: $e');
    }
  }  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      print('Creating product with data: $productData');
      
      // Ensure proper data types
      final cleanData = {
        'name': productData['name']?.toString() ?? '',
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'] is String 
            ? double.tryParse(productData['price']) ?? 0.0
            : (productData['price']?.toDouble() ?? 0.0),
        'image': productData['image']?.toString() ?? '',
        'category_id': productData['category_id'] is String 
            ? int.tryParse(productData['category_id']) ?? null
            : productData['category_id'],
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/admin/products'),
        headers: _headers,
        body: json.encode(cleanData),
      );
      
      print('Create Product Response Status: ${response.statusCode}');
      print('Create Product Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Server error: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in createProduct: $e');
      throw Exception('Error creating product: $e');
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      print('Updating product $id with data: $productData');
      
      // Ensure proper data types
      final cleanData = {
        'name': productData['name']?.toString() ?? '',
        'description': productData['description']?.toString() ?? '',
        'price': productData['price'] is String 
            ? double.tryParse(productData['price']) ?? 0.0
            : (productData['price']?.toDouble() ?? 0.0),
        'image': productData['image']?.toString() ?? '',
        'category_id': productData['category_id'] is String 
            ? int.tryParse(productData['category_id']) ?? null
            : productData['category_id'],
      };
      
      final response = await http.put(
        Uri.parse('$baseUrl/admin/products/$id'),
        headers: _headers,
        body: json.encode(cleanData),
      );
      
      print('Update Product Response Status: ${response.statusCode}');
      print('Update Product Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Server error: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in updateProduct: $e');
      throw Exception('Error updating product: $e');
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      print('Deleting product with ID: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/products/$id'),
        headers: _headers,
      );
      
      print('Delete Product Response Status: ${response.statusCode}');
      print('Delete Product Response Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error in deleteProduct: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  // Category CRUD Operations
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<bool> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
        body: json.encode(categoryData),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: _headers,
        body: json.encode(categoryData),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: _headers,
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
}

