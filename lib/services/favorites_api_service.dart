import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de favoritos (autenticado).
/// GET/POST/DELETE /api/favorites/*
class FavoritesApiService {
  final ApiClient _client;

  FavoritesApiService(this._client);

  /// Listar productos favoritos del usuario.
  /// GET /api/favorites
  Future<List<ApiFavoriteItem>> list() async {
    final data = await _client.get('favorites', authenticated: true);
    final map = data as Map<String, dynamic>;
    return (map['items'] as List<dynamic>)
        .map((e) => ApiFavoriteItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Agregar un producto a favoritos.
  /// POST /api/favorites/:productId
  Future<void> add(String productId) async {
    await _client.post('favorites/$productId', authenticated: true);
  }

  /// Eliminar un producto de favoritos.
  /// DELETE /api/favorites/:productId
  Future<void> remove(String productId) async {
    await _client.delete('favorites/$productId', authenticated: true);
  }
}
