import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

/// Handles authentication for the driver (captain) app.
class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  /// Restore session from a stored token on app startup.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final token = await StorageHelper.getToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _user = data['user'];
      } else {
        await StorageHelper.clear();
        _user = null;
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log in with email + password. Only drivers may use this app.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user']?['role'] != 'driver') {
          _error = 'This app is for drivers only.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        await StorageHelper.setToken(data['token']);
        await StorageHelper.setUser(jsonEncode(data['user']));
        _user = data['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageHelper.clear();
    _user = null;
    notifyListeners();
  }

  /// Register a new driver account.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'driver',
        }),
      );
      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        await StorageHelper.setToken(data['token']);
        await StorageHelper.setUser(jsonEncode(data['user']));
        _user = data['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ??
            (data['errors'] != null && data['errors'].isNotEmpty
                ? data['errors'][0]['msg']
                : 'Registration failed');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
