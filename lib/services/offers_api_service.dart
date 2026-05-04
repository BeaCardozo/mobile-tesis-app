import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de ofertas.
/// GET /api/offers/*
class OffersApiService {
  final ApiClient _client;

  OffersApiService(this._client);

  /// Listar ofertas activas con filtros contextuales opcionales.
  /// GET /api/offers
  Future<List<ApiOffer>> list({
    String? productId,
    String? categoryId,
    String? supermarketId,
    String? storeId,
  }) async {
    final queryParams = <String, String>{};
    if (productId != null) queryParams['productId'] = productId;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (supermarketId != null) queryParams['supermarketId'] = supermarketId;
    if (storeId != null) queryParams['storeId'] = storeId;

    final data = await _client.get('offers', queryParams: queryParams);
    if (data is List) {
      return data
          .map((e) => ApiOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Listar banners para el carousel del home.
  /// GET /api/offers/banners
  Future<List<ApiOffer>> listBanners() async {
    final data = await _client.get('offers/banners');
    if (data is List) {
      return data
          .map((e) => ApiOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Listar ofertas/descuentos detectados en el DWH.
  /// GET /api/offers/deals
  Future<List<ApiDeal>> listDeals({int? limit}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();

    final data = await _client.get('offers/deals', queryParams: queryParams);
    if (data is List) {
      return data
          .map((e) => ApiDeal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
