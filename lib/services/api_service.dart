import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import '../models/menu_item.dart';
import '../models/cafe_location.dart';
import '../models/booking_enquiry.dart';
import '../models/user.dart';

class ApiService {
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 10);

  /// Global callback triggered when any request receives a 401 Unauthorized
  static VoidCallback? onUnauthorized;

  static Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _check401(int statusCode) {
    if (statusCode == 401) {
      debugPrint('[ApiService] Received 401 Unauthorized. Notifying auth listeners.');
      onUnauthorized?.call();
    }
  }

  /// Perform User Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        return {'success': true, 'user': user, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Connection timed out. Please verify your connection.'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Perform User/Restaurant Registration
  static Future<Map<String, dynamic>> register(String name, String email, String password, {String role = 'OWNER'}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'password': password,
              'role': role,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        return {'success': true, 'user': user, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Connection timed out. Please verify your connection.'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Fetch Menu Items (Typed)
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/menu'),
            headers: await _getHeaders(),
          )
          .timeout(_timeout);

      _check401(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => MenuItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching menu items: $e');
    }
    return [];
  }

  /// Add a New Menu Item (Protected: OWNER or ADMIN only)
  static Future<Map<String, dynamic>> createMenuItem({
    required String badge,
    required String category,
    required String name,
    required String description,
    required String image,
    required double price,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/menu'),
            headers: await _getHeaders(requiresAuth: true),
            body: jsonEncode({
              'badge': badge.trim(),
              'category': category.trim(),
              'name': name.trim(),
              'description': description.trim(),
              'image': image.trim(),
              'price': price,
            }),
          )
          .timeout(_timeout);

      _check401(response.statusCode);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Menu item created!',
          'item': MenuItem.fromJson(data['item'] as Map<String, dynamic>),
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create menu item'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Fetch Cafe Locations (Typed)
  static Future<List<CafeLocation>> getLocations() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/locations'),
            headers: await _getHeaders(),
          )
          .timeout(_timeout);

      _check401(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((loc) => CafeLocation.fromJson(loc as Map<String, dynamic>)).toList();
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
    return _submitBookingOrEnquiry(
      endpoint: '/demo-bookings',
      name: name,
      email: email,
      restaurantName: restaurantName,
      phone: phone,
      message: message,
    );
  }

  /// Submit Catering / General Enquiry Request
  static Future<Map<String, dynamic>> submitCateringEnquiry({
    required String name,
    required String email,
    required String eventName,
    required String phone,
    String? message,
  }) async {
    return _submitBookingOrEnquiry(
      endpoint: '/enquiries',
      name: name,
      email: email,
      restaurantName: eventName,
      phone: phone,
      message: message,
    );
  }

  static Future<Map<String, dynamic>> _submitBookingOrEnquiry({
    required String endpoint,
    required String name,
    required String email,
    required String restaurantName,
    required String phone,
    String? message,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'restaurant_name': restaurantName.trim(),
              'phone': phone.trim(),
              'message': message?.trim() ?? '',
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'Request submitted successfully!'};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Submission failed'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Request timed out. Please try again.'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString()}'};
    }
  }

  /// Get Demo Bookings (Protected: OWNER or ADMIN only)
  static Future<List<BookingEnquiry>> getDemoBookings() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/demo-bookings'),
            headers: await _getHeaders(requiresAuth: true),
          )
          .timeout(_timeout);

      _check401(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => BookingEnquiry.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching demo bookings: $e');
    }
    return [];
  }

  /// Get Catering Enquiries (Protected: OWNER or ADMIN only)
  static Future<List<BookingEnquiry>> getEnquiries() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/enquiries'),
            headers: await _getHeaders(requiresAuth: true),
          )
          .timeout(_timeout);

      _check401(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) => BookingEnquiry.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching enquiries: $e');
    }
    return [];
  }
}
