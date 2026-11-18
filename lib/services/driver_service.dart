import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

/// Handles driver-specific data: dashboard, online status, rides, earnings.
class DriverService extends ChangeNotifier {
  bool _isOnline = false;
  bool _isLoading = false;
  Map<String, dynamic>? _dashboard;
  List<dynamic> _rideRequests = [];
  List<dynamic> _earnings = [];

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboard => _dashboard;
  List<dynamic> get rideRequests => _rideRequests;
  List<dynamic> get earnings => _earnings;

  Future<Map<String, String>> _authHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch driver dashboard (stats, earnings, online status, pending rides).
  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/drivers/dashboard'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _dashboard = data['dashboard'];
        _isOnline = data['dashboard']?['isOnline'] ?? false;
      }
    } catch (e) {
      debugPrint('fetchDashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle online/offline status on the backend.
  Future<void> toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/drivers/toggle-status'),
        headers: await _authHeaders(),
        body: jsonEncode({'isOnline': newStatus}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _isOnline = data['isOnline'] ?? newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('toggleOnlineStatus error: $e');
    }
  }

  /// Fetch this driver's rides (accepted/pending etc.).
  Future<void> fetchRideRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/rides/my-rides'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _rideRequests = data['rides'] ?? [];
      }
    } catch (e) {
      debugPrint('fetchRideRequests error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Accept a ride by its rideId.
  Future<bool> acceptRide(String rideId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/rides/$rideId/accept'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchRideRequests();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('acceptRide error: $e');
      return false;
    }
  }

  /// Update ride status (started, completed, etc.).
  Future<bool> updateRideStatus(String rideId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/rides/$rideId/status'),
        headers: await _authHeaders(),
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchRideRequests();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateRideStatus error: $e');
      return false;
    }
  }

  /// Fetch earnings history.
  Future<void> fetchEarnings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/drivers/earnings'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _earnings = data['earnings'] ?? [];
      }
    } catch (e) {
      debugPrint('fetchEarnings error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _driverProfile;
  Map<String, dynamic>? get driverProfile => _driverProfile;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/drivers/profile'),
        headers: await _authHeaders(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _driverProfile = data['driver'];
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/drivers/profile'),
        headers: await _authHeaders(),
        body: jsonEncode(updates),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _driverProfile = data['driver'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }
}
