import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';

/// Online/offline toggle shown on the dashboard.
class StatusToggle extends StatelessWidget {
  const StatusToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverService>(
      builder: (context, driverService, child) {
        final isOnline = driverService.isOnline;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 14,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? Colors.green[800] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Switch(
              value: isOnline,
              activeColor: Colors.green,
              onChanged: (_) => driverService.toggleOnlineStatus(),
            ),
          ],
        );
      },
    );
  }
}
