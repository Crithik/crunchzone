// filepath: c:\Flutter Projects\crunchzone\lib\services\product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  static const String baseUrl = 'http://13.201.189.84/api';
  static Future<List<Product>> fetchProducts() async {
    print('Fetching products from: $baseUrl/products');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      print('Using auth token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      print('Products API Response Status: ${response.statusCode}');
      print('Products API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> productsData;
        
        // Handle different response formats from Laravel
        if (responseData is List) {
          productsData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          productsData = responseData['data'];
        } else if (responseData is Map && responseData.containsKey('products')) {
          productsData = responseData['products'];
        } else {
          print('Unexpected products format: $responseData');
          return []; // Return empty list instead of throwing error
        }
        
        print('Processing ${productsData.length} products');
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Your session may have expired. Please log in again.');
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
    static Future<List<Category>> fetchCategories() async {
    print('Fetching categories from: $baseUrl/categories');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }
      
      print('Using auth token for categories: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      print('Categories API Response Status: ${response.statusCode}');
      print('Categories API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> categoriesData;
        
        // Handle different response formats from Laravel
        if (responseData is List) {
          categoriesData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          categoriesData = responseData['data'];
        } else if (responseData is Map && responseData.containsKey('categories')) {
          categoriesData = responseData['categories'];
        } else {
          print('Unexpected categories format: $responseData');
          return []; // Return empty list instead of throwing error
        }
        
        print('Processing ${categoriesData.length} categories');
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Your session may have expired. Please log in again.');
      } else {
        throw Exception('Failed to load categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}