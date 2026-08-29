import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userStr = prefs.getString('auth_user');

      if (token != null && userStr != null) {
        _token = token;
        _user = json.decode(userStr);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user', json.encode(user));

      _token = token;
      _user = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving login state: $e");
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');

      _token = null;
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }
}
