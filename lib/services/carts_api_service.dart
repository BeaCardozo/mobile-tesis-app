import '../config/api_config.dart';
import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de carritos (autenticado).
/// POST/GET/DELETE /api/carts/*
class CartsApiService {
  final ApiClient _client;

  CartsApiService(this._client);

  /// Listar los carritos del usuario.
  /// GET /api/carts
  Future<List<ApiCartSummary>> list() async {
    final data = await _client.get('carts', authenticated: true);
    final map = data as Map<String, dynamic>;
    return (map['carts'] as List<dynamic>)
        .map((e) => ApiCartSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crear un nuevo carrito.
  /// POST /api/carts
  Future<ApiCartSummary> create(String name) async {
    final data = await _client.post(
      'carts',
      body: {'name': name},
      authenticated: true,
    );
    return ApiCartSummary.fromJson(data as Map<String, dynamic>);
  }

  /// Obtener detalle de un carrito con items.
  /// GET /api/carts/:cartId
  Future<ApiCartDetail> getDetail(String cartId) async {
    final data = await _client.get('carts/$cartId', authenticated: true);
    return ApiCartDetail.fromJson(data as Map<String, dynamic>);
  }

  /// Eliminar un carrito.
  /// DELETE /api/carts/:cartId
  Future<void> delete(String cartId) async {
    await _client.delete('carts/$cartId', authenticated: true);
  }

  /// Agregar item al carrito.
  /// POST /api/carts/:cartId/items
  Future<ApiCartItem> addItem({
    required String cartId,
    required String productId,
    required double quantity,
    String? supermarketId,
  }) async {
    final body = <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
    };
    if (supermarketId != null) body['supermarketId'] = supermarketId;

    final data = await _client.post(
      'carts/$cartId/items',
      body: body,
      authenticated: true,
    );
    return ApiCartItem.fromJson(data as Map<String, dynamic>);
  }

  /// Actualizar cantidad de un item.
  /// PUT /api/carts/:cartId/items/:itemId
  Future<ApiCartItem> updateItem({
    required String cartId,
    required String itemId,
    required double quantity,
  }) async {
    final data = await _client.put(
      'carts/$cartId/items/$itemId',
      body: {'quantity': quantity},
      authenticated: true,
    );
    return ApiCartItem.fromJson(data as Map<String, dynamic>);
  }

  /// Eliminar un item del carrito.
  /// DELETE /api/carts/:cartId/items/:itemId
  Future<void> removeItem({
    required String cartId,
    required String itemId,
  }) async {
    await _client.delete(
      'carts/$cartId/items/$itemId',
      authenticated: true,
    );
  }

  /// Limpiar todos los items del carrito.
  /// DELETE /api/carts/:cartId/items
  Future<void> clearItems(String cartId) async {
    await _client.delete('carts/$cartId/items', authenticated: true);
  }

  /// Comparar precios del carrito entre supermercados.
  /// GET /api/carts/:cartId/compare?mode=single|mixed
  Future<Map<String, dynamic>> compare({
    required String cartId,
    String mode = 'single',
  }) async {
    final data = await _client.get(
      'carts/$cartId/compare',
      queryParams: {'mode': mode},
      authenticated: true,
      timeout: ApiConfig.longTimeout,
    );
    return data as Map<String, dynamic>;
  }
}
