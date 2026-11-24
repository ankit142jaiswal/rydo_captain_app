import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _saving = false;
  late Map<String, bool> _local;

  @override
  void initState() {
    super.initState();
    _local = {};
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = Provider.of<NotificationService>(context, listen: false);
      await service.getSettings();
      setState(() {
        _local = Map<String, bool>.from(service.settings);
        _loading = false;
      });
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final service = Provider.of<NotificationService>(context, listen: false);
    final ok = await service.updateSettings(_local);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Settings saved' : 'Failed to save settings'),
      backgroundColor: ok ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Notification Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _toggle('Ride Updates', 'rideUpdates', Icons.directions_car),
                _toggle('Promotions & Offers', 'promotions', Icons.local_offer),
                _toggle('System Updates', 'systemUpdates', Icons.info),
                _toggle('Security Alerts', 'security', Icons.security),
                _toggle('Earnings Updates', 'earnings', Icons.attach_money),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save Settings'),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () async {
                      await Provider.of<AuthService>(context, listen: false).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (r) => false);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _toggle(String label, String key, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.dark),
        title: Text(label),
        // Switch color comes from theme SwitchThemeData (yellow)
        value: _local[key] ?? true,
        onChanged: (v) => setState(() => _local[key] = v),
      ),
    );
  }
}
