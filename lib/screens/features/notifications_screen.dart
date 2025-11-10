import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final bool _isLoading = false;

  final List<String> _filterOptions = ['All', 'Transactions', 'Security', 'Updates', 'Promotions'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Transaction Successful',
      'message': 'Your payment of \$150.00 to John Smith has been completed successfully.',
      'type': 'Transactions',
      'time': '2 minutes ago',
      'isRead': false,
      'icon': Icons.check_circle,
      'color': AppTheme.successColor,
    },
    {
      'id': '2',
      'title': 'Security Alert',
      'message': 'New login detected from a new device. Please verify if this was you.',
      'type': 'Security',
      'time': '1 hour ago',
      'isRead': false,
      'icon': Icons.security,
      'color': AppTheme.warningColor,
    },
    {
      'id': '3',
      'title': 'Investment Update',
      'message': 'Your portfolio has increased by 2.3% this week. Check out the details.',
      'type': 'Updates',
      'time': '3 hours ago',
      'isRead': true,
      'icon': Icons.trending_up,
      'color': AppTheme.primaryColor,
    },
    {
      'id': '4',
      'title': 'Bill Payment Due',
      'message': 'Your electricity bill of \$89.50 is due in 3 days. Set up auto-pay now.',
      'type': 'Transactions',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.receipt,
      'color': AppTheme.infoColor,
    },
    {
      'id': '5',
      'title': 'Special Offer',
      'message': 'Get 50% off on investment fees this month. Limited time offer!',
      'type': 'Promotions',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.local_offer,
      'color': AppTheme.accentColor,
    },
    {
      'id': '6',
      'title': 'Account Verification',
      'message': 'Please complete your KYC verification to unlock all features.',
      'type': 'Security',
      'time': '3 days ago',
      'isRead': true,
      'icon': Icons.verified_user,
      'color': AppTheme.secondaryColor,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }
    return _notifications.where((notification) => notification['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTheme.heading4.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(
              Icons.done_all,
              color: AppTheme.primaryColor,
            ),
          ),
          IconButton(
            onPressed: _clearAllNotifications,
            icon: Icon(
              Icons.clear_all,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          
          // Notifications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationTile(_filteredNotifications[index], index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.notifications_none,
              color: AppTheme.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppTheme.heading4.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification['icon'],
            color: notification['color'],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
            if (!notification['isRead'])
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              notification['message'],
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification['type'],
                    style: AppTheme.caption.copyWith(
                      color: notification['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  notification['time'],
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppTheme.textSecondary,
          ),
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification['id']);
                break;
              case 'delete':
                _deleteNotification(notification['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Row(
                children: [
                  Icon(
                    notification['isRead'] ? Icons.mark_email_unread : Icons.mark_email_read,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(notification['isRead'] ? 'Mark as unread' : 'Mark as read'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (!notification['isRead']) {
      _markAsRead(notification['id']);
    }
    
    // Handle navigation based on notification type
    switch (notification['type']) {
      case 'Transactions':
        Navigator.pushNamed(context, '/transactions');
        break;
      case 'Security':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'Updates':
        Navigator.pushNamed(context, '/analytics');
        break;
      case 'Promotions':
        // Stay on current screen
        break;
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == notificationId);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Notifications'),
        content: Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Clear All', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
