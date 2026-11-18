import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationService>(context, listen: false).fetchNotifications();
    });
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'ride_update': return Icons.directions_car;
      case 'promotion': return Icons.local_offer;
      case 'security': return Icons.security;
      case 'system': return Icons.info;
      default: return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all read',
            onPressed: () =>
                Provider.of<NotificationService>(context, listen: false).markAllRead(),
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => service.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: service.notifications.length,
              itemBuilder: (context, i) {
                final n = service.notifications[i];
                final isRead = n['isRead'] == true;
                return Dismissible(
                  key: Key(n['_id'] ?? '$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => service.deleteNotification(n['_id']),
                  child: Card(
                    color: isRead ? Colors.white : const Color(0xFFE8F5E9),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                        child: Icon(_typeIcon(n['type'] ?? ''), color: const Color(0xFF4CAF50)),
                      ),
                      title: Text(n['title'] ?? '',
                          style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n['message'] ?? ''),
                      trailing: isRead
                          ? null
                          : const Icon(Icons.circle, size: 10, color: Color(0xFF4CAF50)),
                      onTap: isRead ? null : () => service.markAsRead(n['_id']),
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
