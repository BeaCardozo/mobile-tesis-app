import 'api_client.dart';

/// Metadatos públicos (sin JWT), alineados con ca-api `/meta/fx/current`.
class MetaApiService {
  final ApiClient _client;

  MetaApiService(this._client);

  /// Devuelve Bs por 1 USD o null si falla la petición.
  Future<double?> fxUsdToBs() async {
    try {
      final data = await _client.get('meta/fx/current', authenticated: false);
      if (data is Map && data['fx_usd_to_bs'] != null) {
        final n = (data['fx_usd_to_bs'] as num).toDouble();
        if (n > 0) return n;
      }
    } catch (_) {}
    return null;
  }
}
