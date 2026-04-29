import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de supermercados (GET /api/supermarkets/*).
class SupermarketsApiService {
  final ApiClient _client;

  SupermarketsApiService(this._client);

  /// Listar todos los supermercados activos.
  /// GET /api/supermarkets
  Future<List<ApiSupermarket>> listAll() async {
    final data = await _client.get('supermarkets');
    if (data is List) {
      return data
          .map((e) => ApiSupermarket.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Listar supermercados del DWH (con claves numéricas para filtros).
  /// GET /api/supermarkets/dwh
  Future<List<DwhSupermarket>> listDwh() async {
    final data = await _client.get('supermarkets/dwh');
    if (data is List) {
      return data
          .map((e) => DwhSupermarket.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Obtener detalle de un supermercado.
  /// GET /api/supermarkets/:id
  Future<ApiSupermarket> getDetail(String id) async {
    final data = await _client.get('supermarkets/$id');
    return ApiSupermarket.fromJson(data as Map<String, dynamic>);
  }
}
