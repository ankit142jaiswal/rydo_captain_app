import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_service.dart';
import '../utils/app_colors.dart';

/// Card summarizing the driver's earnings, shown on the dashboard.
class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverService>(
      builder: (context, driverService, child) {
        final dashboard = driverService.dashboard;
        final todayEarnings = dashboard?['today']?['earnings'] ?? 0;
        final monthEarnings = dashboard?['month']?['earnings'] ?? 0;
        final totalEarnings = dashboard?['total']?['earnings'] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.darkGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Earnings",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$todayEarnings',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('This Month', '₹$monthEarnings'),
                  _buildStat('Total', '₹$totalEarnings'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
