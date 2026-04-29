import '../config/api_config.dart';
import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de productos (GET /api/products/*).
class ProductsApiService {
  final ApiClient _client;

  ProductsApiService(this._client);

  /// Listar productos con filtros opcionales.
  /// GET /api/products
  Future<PaginatedResponse<ApiProductSummary>> list({
    String? search,
    String? categoryId,
    String? brandId,
    int? supermarket,
    String? supermarketName,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null) queryParams['category'] = categoryId;
    if (brandId != null) queryParams['brand'] = brandId;
    if (supermarket != null) queryParams['supermarket'] = supermarket.toString();
    if (supermarketName != null) queryParams['supermarketName'] = supermarketName;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    final data = await _client.get('products', queryParams: queryParams);
    final map = data as Map<String, dynamic>;

    final items = (map['items'] as List<dynamic>)
        .map((e) => ApiProductSummary.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      page: map['page'] as int? ?? page,
      limit: map['limit'] as int? ?? limit,
      total: map['total'] as int? ?? items.length,
      items: items,
    );
  }

  /// Obtener productos destacados.
  /// GET /api/products/featured
  Future<List<ApiProductSummary>> featured() async {
    final data = await _client.get('products/featured');
    final map = data as Map<String, dynamic>;
    return (map['items'] as List<dynamic>)
        .map((e) => ApiProductSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtener detalle de un producto con precios actuales.
  /// GET /api/products/:id
  Future<ApiProductDetail> getDetail(String id) async {
    final data = await _client.get('products/$id');
    return ApiProductDetail.fromJson(data as Map<String, dynamic>);
  }

  /// Obtener insights de precios (comparacion + historial).
  /// GET /api/products/:id/prices
  Future<ApiPriceInsights> getPriceInsights(String id, {int days = 30}) async {
    final data = await _client.get(
      'products/$id/prices',
      queryParams: {'days': days.toString()},
      timeout: ApiConfig.longTimeout,
    );
    return ApiPriceInsights.fromJson(data as Map<String, dynamic>);
  }
}
