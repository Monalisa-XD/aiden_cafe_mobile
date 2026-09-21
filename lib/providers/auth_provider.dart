import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  User? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;
  Map<String, dynamic>? get userMap => _user?.toJson();
  bool get isLoading => _isLoading;

  AuthProvider() {
    ApiService.onUnauthorized = logout;
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userStr = prefs.getString('auth_user');

      if (token != null && userStr != null) {
        _token = token;
        _user = User.fromJson(json.decode(userStr) as Map<String, dynamic>);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String token, dynamic user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final User userObj = user is User ? user : User.fromJson(user as Map<String, dynamic>);

      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user', json.encode(userObj.toJson()));

      _token = token;
      _user = userObj;
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
