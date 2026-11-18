import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';

class RideRequestsScreen extends StatefulWidget {
  const RideRequestsScreen({super.key});

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverService>(context, listen: false).fetchRideRequests();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'started':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Requests')),
      body: Consumer<DriverService>(
        builder: (context, driverService, child) {
          if (driverService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = driverService.rideRequests;
          if (rides.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No ride requests yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => driverService.fetchRideRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                final status = ride['status'] ?? 'requested';
                final rideId = ride['rideId'] ?? '';
                final fare = ride['fare']?['total'] ?? 0;
                final pickup = ride['pickup']?['address'] ?? 'N/A';
                final destination = ride['destination']?['address'] ?? 'N/A';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ride['serviceType'] ?? 'Ride',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                status,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: _statusColor(status),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(child: Text(pickup)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(child: Text(destination)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹$fare',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            _buildAction(context, driverService, rideId, status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAction(BuildContext context, DriverService service,
      String rideId, String status) {
    if (status == 'requested') {
      return ElevatedButton(
        onPressed: () => service.acceptRide(rideId),
        child: const Text('Accept'),
      );
    } else if (status == 'accepted') {
      return ElevatedButton(
        onPressed: () => service.updateRideStatus(rideId, 'started'),
        child: const Text('Start'),
      );
    } else if (status == 'started') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () => service.updateRideStatus(rideId, 'completed'),
        child: const Text('Complete'),
      );
    }
    return const SizedBox.shrink();
  }
}
