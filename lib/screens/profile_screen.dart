import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';

const _green = Color(0xFF4CAF50);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  Map<String, dynamic>? _driver;

  final Map<String, bool> _settings = {
    'notifications': true,
    'locationSharing': true,
    'autoAcceptRides': false,
    'soundAlerts': true,
    'nightMode': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final service = Provider.of<DriverService>(context, listen: false);
    await service.fetchProfile();
    setState(() {
      _driver = service.driverProfile ??
          Provider.of<AuthService>(context, listen: false).user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: _green,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: _green,
                    tabs: const [
                      Tab(icon: Icon(Icons.person), text: 'Personal'),
                      Tab(icon: Icon(Icons.directions_car), text: 'Vehicle'),
                      Tab(icon: Icon(Icons.description), text: 'Documents'),
                      Tab(icon: Icon(Icons.settings), text: 'Settings'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _personalTab(),
                      _vehicleTab(),
                      _documentsTab(),
                      _settingsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final d = _driver ?? {};
    final details = d['driverDetails'] ?? {};
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: _green,
                child: Text(
                  (d['name']?.toString() ?? 'D').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(d['name']?.toString() ?? 'Driver',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    if (d['isVerified'] == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: _green, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                    Text(' ${details['rating'] ?? 5.0}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Text('${details['totalRides'] ?? 0} rides',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(details['isOnline'] == true ? 'Online' : 'Active',
                      style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Personal + Performance stats
  Widget _personalTab() {
    final d = _driver ?? {};
    final details = d['driverDetails'] ?? {};
    final rating = (details['rating'] ?? 5.0).toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Personal Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      OutlinedButton.icon(
                        onPressed: _editPersonal,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field('Full Name', d['name']?.toString() ?? 'N/A', Icons.person),
                  _field('Email', d['email']?.toString() ?? 'N/A', Icons.email),
                  _field('Phone', d['phone']?.toString() ?? 'N/A', Icons.phone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Performance Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _statBar('Overall Rating', rating / 5, '${rating.toStringAsFixed(1)}/5.0', _green),
                  _statBar('Completion Rate', 0.96, '96%', Colors.blue),
                  _statBar('Acceptance Rate', 0.89, '89%', Colors.orange),
                  const SizedBox(height: 8),
                  _field('Total Earnings', '₹${(details['earnings'] ?? 0).round()}', Icons.account_balance_wallet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Vehicle Details
  Widget _vehicleTab() {
    final details = (_driver ?? {})['driverDetails'] ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vehicle Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _field('Vehicle Type', details['vehicleType']?.toString() ?? 'N/A', Icons.category),
              _field('Vehicle Number', details['vehicleNumber']?.toString() ?? 'N/A', Icons.confirmation_number),
              _field('Model', details['vehicleModel']?.toString() ?? 'N/A', Icons.directions_car),
              _field('License Number', details['licenseNumber']?.toString() ?? 'N/A', Icons.badge),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 3: Documents
  Widget _documentsTab() {
    final details = (_driver ?? {})['driverDetails'] ?? {};
    final docs = details['documents'] ?? {};
    final docList = [
      {'type': 'Driving License', 'key': 'license', 'icon': Icons.badge},
      {'type': 'Vehicle Registration (RC)', 'key': 'rc', 'icon': Icons.description},
      {'type': 'Insurance Certificate', 'key': 'insurance', 'icon': Icons.shield},
      {'type': 'Driver Photo', 'key': 'photo', 'icon': Icons.photo},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Document Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...docList.map((doc) {
                final uploaded = docs[doc['key']] != null && docs[doc['key']].toString().isNotEmpty;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(doc['icon'] as IconData, color: _green),
                  title: Text(doc['type'] as String),
                  trailing: Chip(
                    label: Text(uploaded ? 'Verified' : 'Pending',
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                    backgroundColor: uploaded ? _green : Colors.orange,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }),
              if (_driver?['isVerified'] != true)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Some documents are under review.',
                        style: TextStyle(color: Colors.blue, fontSize: 13))),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 4: Settings
  Widget _settingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Preferences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _switch('Push Notifications', 'notifications'),
                  _switch('Location Sharing', 'locationSharing'),
                  _switch('Auto Accept Rides', 'autoAcceptRides'),
                  _switch('Sound Alerts', 'soundAlerts'),
                  _switch('Night Mode', 'nightMode'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _action('Change Password', Icons.lock_outline, () => _snack('Contact support')),
                  _action('Update Bank Details', Icons.account_balance, () => _snack('Contact support')),
                  _action('Logout', Icons.logout, _logout, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBar(String label, double value, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(String label, String key) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: _settings[key] ?? false,
      activeColor: _green,
      onChanged: (v) => setState(() => _settings[key] = v),
    );
  }

  Widget _action(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Align(alignment: Alignment.centerLeft, child: Text(label, style: TextStyle(color: color))),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? Colors.grey.shade300),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  Future<void> _editPersonal() async {
    final d = _driver ?? {};
    final nameC = TextEditingController(text: d['name']?.toString() ?? '');
    final phoneC = TextEditingController(text: d['phone']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Personal Information'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final service = Provider.of<DriverService>(context, listen: false);
    final success = await service.updateProfile({'name': nameC.text.trim(), 'phone': phoneC.text.trim()});
    if (!mounted) return;
    if (success) {
      setState(() => _driver = service.driverProfile);
      _snack('Profile updated');
    } else {
      _snack('Update failed');
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
