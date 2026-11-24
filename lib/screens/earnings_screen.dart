import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';
import '../utils/app_colors.dart';
import '../widgets/earnings_card.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<DriverService>(context, listen: false);
      service.fetchDashboard();
      service.fetchEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: Consumer<DriverService>(
        builder: (context, driverService, child) {
          return RefreshIndicator(
            onRefresh: () => driverService.fetchEarnings(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const EarningsCard(),
                const SizedBox(height: 20),
                const Text(
                  'Earnings History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (driverService.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (driverService.earnings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No earnings yet',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...driverService.earnings.map((e) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: const Icon(
                            Icons.directions_car,
                            color: AppColors.dark,
                          ),
                        ),
                        title: Text(e['customer']?.toString() ?? 'Customer'),
                        subtitle: Text(
                          '${e['serviceType'] ?? ''} • ${e['distance'] ?? 0} km',
                        ),
                        trailing: Text(
                          '₹${e['earning'] ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
