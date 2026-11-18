import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';

/// Real-time socket connection for the driver (captain) app.
///
/// On connect it joins the `driver_<id>` room so the backend can push
/// targeted `new_ride_request` events for rides near this driver.
class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  bool _connected = false;
  String? _driverId;

  bool get connected => _connected;

  /// Stream of incoming ride requests (each is the socket payload map).
  final StreamController<Map<String, dynamic>> _rideRequestController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get rideRequests => _rideRequestController.stream;

  void connect(String driverId) {
    if (_socket != null && _connected && _driverId == driverId) return;
    _driverId = driverId;

    _socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      // Join the driver's room to receive targeted ride requests
      _socket!.emit('join_driver', driverId);
      notifyListeners();
      debugPrint('Socket connected, joined driver_$driverId');
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      notifyListeners();
      debugPrint('Socket disconnected');
    });

    _socket!.on('new_ride_request', (data) {
      if (data is Map) {
        _rideRequestController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
    _driverId = null;
  }

  @override
  void dispose() {
    _rideRequestController.close();
    disconnect();
    super.dispose();
  }
}
