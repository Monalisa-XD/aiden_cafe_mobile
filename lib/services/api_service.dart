import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final http.Client _client = http.Client();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Perform User Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Perform User/Restaurant Registration
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'OWNER',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Fetch Menu Items
  static Future<List<Map<String, String>>> getMenuItems() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/menu'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) {
          return {
            'id': item['id'].toString(),
            'badge': item['badge'].toString(),
            'category': item['category'].toString(),
            'name': item['name'].toString(),
            'description': item['description'].toString(),
            'image': item['image'].toString(),
          };
        }).toList();
      }
    } catch (e) {
      // In case of error, fall back to empty list or let UI handle it
      debugPrint('Error fetching menu items: $e');
    }
    return [];
  }

  /// Fetch Cafe Locations
  static Future<List<Map<String, String>>> getLocations() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/locations'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((loc) {
          return {
            'id': loc['id'].toString(),
            'name': loc['name'].toString(),
            'address': loc['address'].toString(),
            'image': loc['image'].toString(),
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
    }
    return [];
  }

  /// Submit Demo Booking Request
  static Future<Map<String, dynamic>> submitDemoBooking({
    required String name,
    required String email,
    required String restaurantName,
    required String phone,
    String? message,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/demo-bookings'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'restaurant_name': restaurantName,
          'phone': phone,
          'message': message ?? '',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Booking failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }
}

