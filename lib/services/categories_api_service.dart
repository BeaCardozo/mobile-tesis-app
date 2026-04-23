import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de categorias (GET /api/categories/*).
class CategoriesApiService {
  final ApiClient _client;

  CategoriesApiService(this._client);

  /// Listar todas las categorias.
  /// GET /api/categories
  Future<List<ApiCategory>> listAll() async {
    final data = await _client.get('categories');
    if (data is List) {
      return data
          .map((e) => ApiCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Obtener detalle de una categoria.
  /// GET /api/categories/:id
  Future<ApiCategory> getDetail(String id) async {
    final data = await _client.get('categories/$id');
    return ApiCategory.fromJson(data as Map<String, dynamic>);
  }
}
