import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';
import '../widgets/status_toggle.dart';

const _green = Color(0xFF4CAF50);
const _greenGradient = LinearGradient(
  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Map<String, dynamic>>? _rideSub;

  @override
  void initState() {
    super.initState();
    _initializeDriver();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSocket());
  }

  void _initSocket() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final socket = Provider.of<SocketService>(context, listen: false);
    final driverId = auth.user?['id']?.toString() ??
        auth.user?['_id']?.toString() ??
        auth.user?['userId']?.toString();
    if (driverId != null) {
      socket.connect(driverId);
    }
    // Listen for incoming ride requests pushed from the backend
    _rideSub = socket.rideRequests.listen(_onNewRideRequest);
  }

  void _onNewRideRequest(Map<String, dynamic> data) {
    if (!mounted) return;

    // Refresh notifications + ride requests so lists stay in sync
    Provider.of<NotificationService>(context, listen: false).fetchNotifications();
    Provider.of<DriverService>(context, listen: false).fetchRideRequests();

    final pickup = (data['pickup']?['address'])?.toString() ?? 'Pickup';
    final destination = (data['destination']?['address'])?.toString() ?? 'Destination';
    final fare = data['fare'] ?? 0;
    final serviceType = data['serviceType']?.toString() ?? 'Ride';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.directions_car, color: _green),
            SizedBox(width: 8),
            Text('New Ride Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceType.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: _green)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.my_location, size: 16, color: _green),
              const SizedBox(width: 6),
              Expanded(child: Text(pickup)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(child: Text(destination)),
            ]),
            const SizedBox(height: 8),
            Text('Fare: ₹$fare',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/ride-requests');
            },
            child: const Text('View Requests'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  void _initializeDriver() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final driverService = Provider.of<DriverService>(context, listen: false);
    await driverService.fetchDashboard();
    await locationService.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('RYDO Captain'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer2<DriverService, LocationService>(
        builder: (context, driverService, locationService, child) {
          return RefreshIndicator(
            onRefresh: () => driverService.fetchDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcome(driverService),
                const SizedBox(height: 16),

                // Online/offline status toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const StatusToggle(),
                ),
                const SizedBox(height: 16),

                _buildStatsRow(driverService),
                const SizedBox(height: 20),

                // Map section
                const Text('Your Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 220,
                    child: locationService.currentPosition != null
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                locationService.currentPosition!.latitude,
                                locationService.currentPosition!.longitude,
                              ),
                              zoom: 15,
                            ),
                            onMapCreated: (c) => _mapController = c,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick actions
                const Text('Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/ride-requests'),
                        icon: const Icon(Icons.list),
                        label: const Text('Ride Requests'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/earnings'),
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Earnings'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcome(DriverService driverService) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _greenGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${auth.user?['name']?.toString().split(' ')[0] ?? 'Captain'}!',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                driverService.isOnline
                    ? "You're online — ready for rides"
                    : "You're offline — go online to earn",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(DriverService driverService) {
    final d = driverService.dashboard ?? {};
    final today = d['today'] ?? {};
    final total = d['total'] ?? {};
    final rating = d['rating'] ?? 5.0;
    return Row(
      children: [
        _statCard("Today's Earnings", '₹${today['earnings'] ?? 0}', Icons.attach_money, _green),
        const SizedBox(width: 12),
        _statCard("Today's Rides", '${today['rides'] ?? 0}', Icons.directions_car, Colors.blue),
        const SizedBox(width: 12),
        _statCard('Rating', '$rating', Icons.star, Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    Widget item(IconData icon, String label, String route) {
      return ListTile(
        leading: Icon(icon, color: _green),
        title: Text(label),
        onTap: () {
          Navigator.pop(context);
          if (route != '/dashboard') Navigator.pushNamed(context, route);
        },
      );
    }

    return Drawer(
      child: Consumer<AuthService>(
        builder: (context, auth, child) {
          final user = auth.user ?? {};
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(gradient: _greenGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Text(
                        (user['name']?.toString() ?? 'C').substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: _green, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(user['name']?.toString() ?? 'RYDO Captain',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user['email']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              item(Icons.dashboard, 'Dashboard', '/dashboard'),
              item(Icons.list_alt, 'Ride Requests', '/ride-requests'),
              item(Icons.history, 'Ride History', '/ride-history'),
              item(Icons.attach_money, 'Earnings', '/earnings'),
              item(Icons.notifications, 'Notifications', '/notifications'),
              item(Icons.person, 'Profile', '/profile'),
              item(Icons.settings, 'Settings', '/settings'),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
