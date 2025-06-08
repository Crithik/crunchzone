import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";
  String _userEmail = "";
  bool _isAdmin = false;
  String _authToken = "";
  static const String baseUrl = 'http://13.201.189.84/api';
  
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;
  String get authToken => _authToken;
  
  AuthService() {
    _checkLoginStatus();
  }
    Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userName = prefs.getString('userName');
      final userEmail = prefs.getString('userEmail');
      final isAdmin = prefs.getBool('isAdmin');
      
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        _userName = userName ?? '';
        _userEmail = userEmail ?? '';
        _isAdmin = isAdmin ?? false;
        _authToken = token;
        notifyListeners();
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }
  
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url, 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
        if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? data['access_token'];

        if (token == null) {
          print('Token not found in response');
          return false;
        }

        // Extract user details from response
        final user = data['user'] ?? data;
        _userName = user['name'] ?? email.split('@')[0];
        _userEmail = user['email'] ?? email;
        _isAdmin = user['is_admin'] == true || user['is_admin'] == 1;
        _authToken = token;

        // Check if user is admin
        bool isAdminUser = (_userEmail == 'admin@gmail.com' && _userName == 'Admin') || _isAdmin;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userName', _userName);
        await prefs.setString('userEmail', _userEmail);
        await prefs.setBool('isAdmin', isAdminUser);

        _isLoggedIn = true;
        _isAdmin = isAdminUser;
        notifyListeners();
        return true;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  Future<bool> register(String email, String password, String name) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      print('Attempting to register user: $email');
      
      final response = await http.post(
        url, 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'] ?? data['access_token'];
        
        _userName = name;
        _userEmail = email;
        _isAdmin = false; // Regular users are not admin by default
        _authToken = token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);
        await prefs.setBool('isAdmin', false);

        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('isAdmin');
      
      _isLoggedIn = false;
      _userName = "";
      _userEmail = "";
      _isAdmin = false;
      _authToken = "";
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Helper method for making authenticated API calls
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Helper method for making authenticated GET requests
  Future<http.Response> authenticatedGet(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: getAuthHeaders());
  }

  // Helper method for making authenticated POST requests
  Future<http.Response> authenticatedPost(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: getAuthHeaders(),
      body: json.encode(body),
    );
  }
}