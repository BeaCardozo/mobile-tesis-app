import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de notificaciones (autenticado).
/// GET/PUT /api/notifications/*
class NotificationsApiService {
  final ApiClient _client;

  NotificationsApiService(this._client);

  /// Listar notificaciones del usuario.
  /// GET /api/notifications
  Future<List<ApiNotification>> list() async {
    final data = await _client.get('notifications', authenticated: true);
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => ApiNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Obtener conteo de no leidas.
  /// GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    final data =
        await _client.get('notifications/unread-count', authenticated: true);
    if (data is Map) {
      return data['unreadCount'] as int? ?? 0;
    }
    return 0;
  }

  /// Marcar una notificacion como leida.
  /// PUT /api/notifications/:id/read
  Future<void> markAsRead(String id) async {
    await _client.put('notifications/$id/read', authenticated: true);
  }

  /// Marcar todas como leidas.
  /// PUT /api/notifications/read-all
  Future<void> markAllAsRead() async {
    await _client.put('notifications/read-all', authenticated: true);
  }

  /// Registrar device token para push.
  /// POST /api/notifications/subscribe
  Future<void> subscribe({
    required String token,
    String? platform,
  }) async {
    await _client.post(
      'notifications/subscribe',
      body: {
        'token': token,
        if (platform != null) 'platform': platform,
      },
      authenticated: true,
    );
  }
}
