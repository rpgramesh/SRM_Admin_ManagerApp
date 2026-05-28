import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_tokens.dart';
import '../services/firestore_service.dart';
import '../models/notification.dart';
import '../config/app_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late FirestoreService _firestoreService;
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'unread', 'orders', 'delivery'];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: DesignTokens.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                selectedColor: DesignTokens.primaryGreen.withOpacity(0.2),
                checkmarkColor: DesignTokens.primaryGreen,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    // For demo purposes, using a mock customer ID
    final String customerId = AppConfig.mockCustomerId;
    
    return StreamBuilder<List<AppNotification>>(
      stream: _firestoreService.getNotificationsByRecipient(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        List<AppNotification> notifications = snapshot.data!;
        
        // Filter notifications based on selected filter
        notifications = _filterNotifications(notifications);
        
        // Sort notifications by timestamp (newest first)
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification);
          },
        );
      },
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'orders':
        return notifications.where((n) => 
          n.type == NotificationType.orderPlaced ||
          n.type == NotificationType.orderConfirmed ||
          n.type == NotificationType.orderReady ||
          n.type == NotificationType.orderDelivered
        ).toList();
      case 'delivery':
        return notifications.where((n) => 
          n.type == NotificationType.deliveryAssigned ||
          n.type == NotificationType.deliveryPickedUp ||
          n.type == NotificationType.deliveryDelivered
        ).toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : Colors.blue.shade50,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: notification.isRead 
          ? null 
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: DesignTokens.primaryGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        onTap: () => _onNotificationTap(notification),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'unread':
        return 'Unread';
      case 'orders':
        return 'Orders';
      case 'delivery':
        return 'Delivery';
      default:
        return filter;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
        return Colors.blue;
      case NotificationType.orderReady:
        return Colors.orange;
      case NotificationType.orderDelivered:
        return Colors.green;
      case NotificationType.deliveryAssigned:
        return Colors.purple;
      case NotificationType.deliveryPickedUp:
        return Colors.amber;
      case NotificationType.deliveryDelivered:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
        return Icons.shopping_cart;
      case NotificationType.orderConfirmed:
        return Icons.check_circle;
      case NotificationType.orderReady:
        return Icons.restaurant;
      case NotificationType.orderDelivered:
        return Icons.delivery_dining;
      case NotificationType.deliveryAssigned:
        return Icons.person;
      case NotificationType.deliveryPickedUp:
        return Icons.local_shipping;
      case NotificationType.deliveryDelivered:
        return Icons.home;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _onNotificationTap(AppNotification notification) async {
    // Mark notification as read
    if (!notification.isRead) {
      try {
        await _firestoreService.markNotificationAsRead(notification.id);
      } catch (e) {
        // Handle error silently
      }
    }

    // Navigate based on notification type
    if (notification.orderId != null) {
      // Navigate to order tracking screen
      Navigator.pushNamed(
        context,
        '/order-tracking',
        arguments: notification.orderId,
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      //final String customerId = AppConfig.currentUserId;
      // final unreadNotifications = await _firestoreService
      //     .getNotificationsForRecipient(customerId)
      //     .then((notifications) => notifications.where((n) => !n.isRead).toList());
      
      // for (final notification in unreadNotifications) {
      //   await _firestoreService.markNotificationAsRead(notification.id);
      // }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark notifications as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}