import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';
import '../services/socket_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

// ─── DashboardScreen ─────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  StreamSubscription<Map<String, dynamic>>? _rideSub;

  // The four tab bodies — built lazily via IndexedStack
  final List<_TabBody> _tabs = [
    const _HomeTab(),
    const _RidesTab(),
    const _EarningsTab(),
    const _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDriver();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSocket());
  }

  // ── Socket init (unchanged logic) ────────────────────────────────────────
  void _initSocket() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final socket = Provider.of<SocketService>(context, listen: false);
    final driverId = auth.user?['id']?.toString() ??
        auth.user?['_id']?.toString() ??
        auth.user?['userId']?.toString();
    if (driverId != null) {
      socket.connect(driverId);
    }
    _rideSub = socket.rideRequests.listen(_onNewRideRequest);
  }

  void _onNewRideRequest(Map<String, dynamic> data) {
    if (!mounted) return;

    Provider.of<NotificationService>(context, listen: false)
        .fetchNotifications();
    Provider.of<DriverService>(context, listen: false).fetchRideRequests();

    final pickup =
        (data['pickup']?['address'])?.toString() ?? 'Pickup';
    final destination =
        (data['destination']?['address'])?.toString() ?? 'Destination';
    final fare = data['fare'] ?? 0;
    final serviceType =
        data['serviceType']?.toString() ?? 'Ride';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.directions_car_rounded, color: AppColors.dark),
            SizedBox(width: 8),
            Text('New Ride Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                serviceType.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            _rideDialogRow(
                Icons.my_location_rounded, AppColors.primaryLight, pickup),
            const SizedBox(height: 6),
            _rideDialogRow(
                Icons.location_on_rounded, Colors.red, destination),
            const SizedBox(height: 12),
            Text(
              '₹$fare',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark),
            ),
            const Text('Estimated fare',
                style:
                    TextStyle(fontSize: 11, color: Color(0xFF607D8B))),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('View Requests'),
          ),
        ],
      ),
    );
  }

  Widget _rideDialogRow(IconData icon, Color color, String text) =>
      Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis)),
      ]);

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  void _initializeDriver() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final driverService =
        Provider.of<DriverService>(context, listen: false);
    await driverService.fetchDashboard();
    await locationService.getCurrentLocation();
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─── Modern BottomNavigationBar ───────────────────────────────────────────────
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomNav(
      {required this.currentIndex, required this.onTap});

  static const _items = [
    BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard'),
    BottomNavigationBarItem(
        icon: Icon(Icons.directions_car_outlined),
        activeIcon: Icon(Icons.directions_car_rounded),
        label: 'Rides'),
    BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        activeIcon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Earnings'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: _items,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.dark,
          unselectedItemColor: const Color(0xFF90A4AE),
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

// ─── Tab body base ────────────────────────────────────────────────────────────
abstract class _TabBody extends Widget {
  const _TabBody({super.key});
}

// ─── Home / Dashboard tab ────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget implements _TabBody {
  const _HomeTab({super.key});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Consumer2<DriverService, LocationService>(
        builder: (context, driverService, locationService, _) {
          return RefreshIndicator(
            color: AppColors.dark,
            onRefresh: () => driverService.fetchDashboard(),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: (mq.size.width * 0.045).clamp(14.0, 24.0),
                vertical: 20,
              ),
              children: [
                // ── Welcome card ────────────────────────────────────────
                _WelcomeCard(driverService: driverService),
                const SizedBox(height: 16),

                // ── Online / Offline toggle card ────────────────────────
                _OnlineToggleCard(driverService: driverService),
                const SizedBox(height: 16),

                // ── Today's stats ───────────────────────────────────────
                _TodaysStatsSection(driverService: driverService),
                const SizedBox(height: 20),

                // ── Earnings summary ────────────────────────────────────
                _EarningsSummarySection(driverService: driverService),
                const SizedBox(height: 20),

                // ── Live map ────────────────────────────────────────────
                _SectionHeader(
                    title: 'Your Location',
                    icon: Icons.map_outlined),
                const SizedBox(height: 10),
                _LiveMapCard(
                    locationService: locationService,
                    onMapCreated: (_) {}),
                const SizedBox(height: 20),

                // ── Quick actions ───────────────────────────────────────
                _SectionHeader(
                    title: 'Quick Actions',
                    icon: Icons.flash_on_rounded),
                const SizedBox(height: 10),
                _QuickActionsRow(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Rydo Captain'),
      backgroundColor: AppColors.dark,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () =>
              Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    Widget item(IconData icon, String label, String route) {
      return ListTile(
        leading: Icon(icon, color: AppColors.dark, size: 22),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        onTap: () {
          Navigator.pop(context);
          if (route != '/dashboard') {
            Navigator.pushNamed(context, route);
          }
        },
      );
    }

    return Drawer(
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          final user = auth.user ?? {};
          final initial = (user['name']?.toString() ?? 'C')
              .substring(0, 1)
              .toUpperCase();
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration:
                    const BoxDecoration(gradient: AppColors.darkGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: const TextStyle(
                            color: AppColors.dark,
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user['name']?.toString() ?? 'Rydo Captain',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user['email']?.toString() ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              item(Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
              item(Icons.list_alt_rounded, 'Ride Requests',
                  '/ride-requests'),
              item(Icons.history_rounded, 'Ride History',
                  '/ride-history'),
              item(Icons.account_balance_wallet_rounded, 'Earnings',
                  '/earnings'),
              item(Icons.notifications_rounded, 'Notifications',
                  '/notifications'),
              item(Icons.person_rounded, 'Profile', '/profile'),
              item(Icons.settings_rounded, 'Settings', '/settings'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded,
                    color: Color(0xFFD32F2F), size: 22),
                title: const Text('Log Out',
                    style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (r) => false);
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

// ─── Rides tab (wraps existing screen logic inline) ──────────────────────────
class _RidesTab extends StatelessWidget implements _TabBody {
  const _RidesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Rides'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Ride Requests',
            onPressed: () =>
                Navigator.pushNamed(context, '/ride-requests'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_rounded,
                size: 64, color: AppColors.dark.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Ride Management',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tap below to view pending requests or history',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF607D8B)),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('Ride Requests'),
                      onPressed: () => Navigator.pushNamed(
                          context, '/ride-requests'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('Ride History'),
                      onPressed: () => Navigator.pushNamed(
                          context, '/ride-history'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Earnings tab ─────────────────────────────────────────────────────────────
class _EarningsTab extends StatelessWidget implements _TabBody {
  const _EarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, '/earnings'),
          ),
        ],
      ),
      body: Consumer<DriverService>(
        builder: (context, ds, _) {
          final d = ds.dashboard ?? {};
          final today = d['today'] ?? {};
          final total = d['total'] ?? {};
          final mq = MediaQuery.of(context);

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: (mq.size.width * 0.05).clamp(14.0, 24.0),
              vertical: 20,
            ),
            children: [
              _EarningsHeroCard(
                todayEarnings: today['earnings'] ?? 0,
                totalEarnings: total['earnings'] ?? 0,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: _MiniStatCard(
                    label: "Today's Rides",
                    value: '${today['rides'] ?? 0}',
                    icon: Icons.directions_car_rounded,
                    color: const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Total Rides',
                    value: '${total['rides'] ?? 0}',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF6A1B9A),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Full Earnings Report'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/earnings'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Profile tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget implements _TabBody {
  const _ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, auth, _) {
          final user = auth.user ?? {};
          final mq = MediaQuery.of(context);

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: (mq.size.width * 0.05).clamp(14.0, 24.0),
              vertical: 20,
            ),
            children: [
              // Avatar + name
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        (user['name']?.toString() ?? 'C')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user['name']?.toString() ?? 'Captain',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email']?.toString() ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Quick links
              _ProfileLinkTile(
                  icon: Icons.person_rounded,
                  label: 'Edit Profile',
                  route: '/profile'),
              _ProfileLinkTile(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: '/settings'),
              _ProfileLinkTile(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  route: '/notifications'),
              const SizedBox(height: 8),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Divider()),
              const SizedBox(height: 4),
              ListTile(
                leading: const Icon(Icons.logout_rounded,
                    color: Color(0xFFD32F2F)),
                title: const Text('Log Out',
                    style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFFFF3F3),
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (r) => false);
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

// ─── Reusable components ──────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final DriverService driverService;

  const _WelcomeCard({required this.driverService});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final name = auth.user?['name']?.toString().split(' ')[0] ?? 'Captain';
        final online = driverService.isOnline;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.darkGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.dark.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      online
                          ? "You're online — ready for rides"
                          : "You're offline — go online to earn",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: online
                      ? Colors.white.withOpacity(0.22)
                      : Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: online
                            ? const Color(0xFF76FF03)
                            : Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      online ? 'Online' : 'Offline',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Online / Offline toggle — big, prominent card
class _OnlineToggleCard extends StatelessWidget {
  final DriverService driverService;

  const _OnlineToggleCard({required this.driverService});

  @override
  Widget build(BuildContext context) {
    final isOnline = driverService.isOnline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline
              ? AppColors.primaryLight.withOpacity(0.5)
              : const Color(0xFFCFD8DC),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.dark.withOpacity(0.1)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: isOnline ? AppColors.dark : const Color(0xFF90A4AE),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isOnline
                        ? AppColors.dark
                        : const Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Accepting ride requests'
                      : 'Tap to start accepting rides',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF607D8B)),
                ),
              ],
            ),
          ),

          // Toggle switch
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: isOnline,
              onChanged: driverService.isLoading
                  ? null
                  : (_) => driverService.toggleOnlineStatus(),
              activeColor: AppColors.dark,
              activeTrackColor: AppColors.primaryLight.withOpacity(0.4),
              inactiveThumbColor: const Color(0xFF90A4AE),
              inactiveTrackColor: const Color(0xFFCFD8DC),
            ),
          ),
        ],
      ),
    );
  }
}

// Today's stats row
class _TodaysStatsSection extends StatelessWidget {
  final DriverService driverService;

  const _TodaysStatsSection({required this.driverService});

  @override
  Widget build(BuildContext context) {
    final d = driverService.dashboard ?? {};
    final today = d['today'] ?? {};
    final rating = d['rating'] ?? 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            title: "Today's Stats",
            icon: Icons.today_rounded),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _MiniStatCard(
              label: "Earnings",
              value: '₹${today['earnings'] ?? 0}',
              icon: Icons.attach_money_rounded,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: "Rides",
              value: '${today['rides'] ?? 0}',
              icon: Icons.directions_car_rounded,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStatCard(
              label: "Rating",
              value: '$rating',
              icon: Icons.star_rounded,
              color: const Color(0xFFFB8C00),
            ),
          ),
        ]),
      ],
    );
  }
}

// Earnings summary section
class _EarningsSummarySection extends StatelessWidget {
  final DriverService driverService;

  const _EarningsSummarySection({required this.driverService});

  @override
  Widget build(BuildContext context) {
    final d = driverService.dashboard ?? {};
    final today = d['today'] ?? {};
    final total = d['total'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
            title: 'Earnings Summary',
            icon: Icons.account_balance_wallet_rounded),
        const SizedBox(height: 10),
        _EarningsHeroCard(
          todayEarnings: today['earnings'] ?? 0,
          totalEarnings: total['earnings'] ?? 0,
        ),
      ],
    );
  }
}

// Live map card
class _LiveMapCard extends StatelessWidget {
  final LocationService locationService;
  final void Function(GoogleMapController) onMapCreated;

  const _LiveMapCard(
      {required this.locationService, required this.onMapCreated});

  @override
  Widget build(BuildContext context) {
    final pos = locationService.currentPosition;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: pos != null
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pos.latitude, pos.longitude),
                  zoom: 15,
                ),
                onMapCreated: onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              )
            : Container(
                color: const Color(0xFFEEF2F5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.dark),
                      SizedBox(height: 10),
                      Text('Getting your location…',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF607D8B))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// Quick actions row
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.list_alt_rounded, size: 18),
          label: const Text('Ride Requests'),
          onPressed: () =>
              Navigator.pushNamed(context, '/ride-requests'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.account_balance_wallet_rounded,
              size: 18),
          label: const Text('Earnings'),
          onPressed: () =>
              Navigator.pushNamed(context, '/earnings'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ]);
  }
}

// Section header with icon
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.dark),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      ),
    ]);
  }
}

// Mini stat card
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF607D8B),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Earnings hero card
class _EarningsHeroCard extends StatelessWidget {
  final dynamic todayEarnings;
  final dynamic totalEarnings;

  const _EarningsHeroCard({
    required this.todayEarnings,
    required this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Earnings",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$todayEarnings',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white.withOpacity(0.25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earned',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$totalEarnings',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Profile link tile
class _ProfileLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _ProfileLinkTile(
      {required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.dark.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.dark, size: 20),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF90A4AE)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: Colors.white,
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

