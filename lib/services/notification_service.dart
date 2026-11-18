import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

/// Handles driver notifications and notification settings.
class NotificationService extends ChangeNotifier {
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Map<String, bool> _settings = {
    'rideUpdates': true,
    'promotions': true,
    'systemUpdates': true,
    'security': true,
    'earnings': true,
  };

  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  Map<String, bool> get settings => _settings;

  Future<Map<String, String>> _headers() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _notifications = data['notifications'] ?? [];
        _unreadCount = data['unreadCount'] ?? 0;
      }
    } catch (e) {
      debugPrint('fetchNotifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: await _headers(),
      );
      await fetchNotifications();
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/mark-all-read'),
        headers: await _headers(),
      );
      await fetchNotifications();
    } catch (e) {
      debugPrint('markAllRead error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id'),
        headers: await _headers(),
      );
      await fetchNotifications();
    } catch (e) {
      debugPrint('deleteNotification error: $e');
    }
  }

  Future<void> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/settings'),
        headers: await _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true && data['settings'] != null) {
        final s = data['settings'];
        _settings = {
          'rideUpdates': s['rideUpdates'] ?? true,
          'promotions': s['promotions'] ?? true,
          'systemUpdates': s['systemUpdates'] ?? true,
          'security': s['security'] ?? true,
          'earnings': s['earnings'] ?? true,
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('getSettings error: $e');
    }
  }

  Future<bool> updateSettings(Map<String, bool> newSettings) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/settings'),
        headers: await _headers(),
        body: jsonEncode(newSettings),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _settings = {..._settings, ...newSettings};
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateSettings error: $e');
      return false;
    }
  }
}
