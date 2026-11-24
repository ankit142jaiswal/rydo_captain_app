import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';
import '../utils/app_colors.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverService>(context, listen: false).fetchRideRequests();
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return AppColors.completed;
      case 'cancelled': return Colors.red;
      case 'started': return Colors.purple;
      case 'accepted': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: Consumer<DriverService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show completed and cancelled rides
          final history = service.rideRequests
              .where((r) => r['status'] == 'completed' || r['status'] == 'cancelled')
              .toList();

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No ride history yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.fetchRideRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, i) {
                final ride = history[i];
                final status = ride['status'] ?? '';
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
                            Text(ride['serviceType'] ?? 'Ride',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Chip(
                              label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: _statusColor(status),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.my_location, size: 15, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(child: Text(ride['pickup']?['address'] ?? 'N/A')),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on, size: 15, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(child: Text(ride['destination']?['address'] ?? 'N/A')),
                        ]),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${ride['fare']?['total'] ?? 0}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              ride['createdAt'] != null
                                  ? DateTime.tryParse(ride['createdAt'])?.toLocal().toString().split('.')[0] ?? ''
                                  : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
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
}
