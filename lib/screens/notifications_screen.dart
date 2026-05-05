import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/api_models.dart';
import '../services/api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<ApiNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await Api.instance.notifications.list();
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar notificaciones';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await Api.instance.notifications.markAllAsRead();
      setState(() {
        _notifications = _notifications
            .map((n) => ApiNotification(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  type: n.type,
                  data: n.data,
                  readAt: n.readAt ?? DateTime.now().toIso8601String(),
                  createdAt: n.createdAt,
                ))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _markAsRead(ApiNotification notification) async {
    if (notification.isRead) return;
    try {
      await Api.instance.notifications.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = ApiNotification(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            data: notification.data,
            readAt: DateTime.now().toIso8601String(),
            createdAt: notification.createdAt,
          );
        }
      });
    } catch (_) {}
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Leer todas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? _buildError()
              : _notifications.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error.withOpacity(0.6)),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadNotifications,
            child: const Text('Reintentar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Te notificaremos cuando haya nuevas ofertas y actualizaciones de precios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _markAsRead(notification),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final ApiNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'offer':
        return Icons.local_offer_rounded;
      case 'price_drop':
        return Icons.trending_down_rounded;
      case 'new_product':
        return Icons.new_releases_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'offer':
        return Colors.orange;
      case 'price_drop':
        return AppColors.primary;
      case 'new_product':
        return Colors.blue;
      default:
        return AppColors.accent;
    }
  }

  String get _timeAgo {
    try {
      final date = DateTime.parse(notification.createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} dias';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AppColors.grey.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null &&
                      notification.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey.withOpacity(0.6),
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
