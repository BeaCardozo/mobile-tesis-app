import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Excepcion personalizada para errores de la API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({required this.statusCode, required this.message, this.errors});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Excepcion para cuando no hay conexion a internet.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexion a internet']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Cliente HTTP centralizado para comunicarse con ca-api.
/// Maneja autenticacion JWT, refresh automatico de tokens,
/// y formato estandar de respuestas.
class ApiClient {
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyRememberMe = 'rememberMe';
  static const String _keyRememberEmail = 'rememberEmail';

  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // ---------------------------------------------------------------------------
  // Gestion de tokens
  // ---------------------------------------------------------------------------

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  Future<void> saveRememberMe(bool value, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
    if (value && email != null) {
      await prefs.setString(_keyRememberEmail, email);
    } else if (!value) {
      await prefs.remove(_keyRememberEmail);
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  Future<String?> getRememberEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberEmail);
  }

  bool get isDisposed => _disposed;
  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _httpClient.close();
  }

  // ---------------------------------------------------------------------------
  // Metodos HTTP publicos
  // ---------------------------------------------------------------------------

  /// GET request. [authenticated] determina si se envia el Bearer token.
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool authenticated = false,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = await _buildHeaders(authenticated: authenticated);
    return _executeWithRetry(
      () => _httpClient.get(uri, headers: headers).timeout(
            timeout ?? ApiConfig.timeout,
          ),
      authenticated: authenticated,
      retryRequest: () => _retryGet(uri, timeout),
    );
  }

  /// POST request.
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final headers = await _buildHeaders(authenticated: authenticated);
    return _executeWithRetry(
      () => _httpClient
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(timeout ?? ApiConfig.timeout),
      authenticated: authenticated,
      retryRequest: () => _retryPost(uri, body, timeout),
    );
  }

  /// PUT request.
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final headers = await _buildHeaders(authenticated: authenticated);
    return _executeWithRetry(
      () => _httpClient
          .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(timeout ?? ApiConfig.timeout),
      authenticated: authenticated,
      retryRequest: () => _retryPut(uri, body, timeout),
    );
  }

  /// DELETE request.
  Future<dynamic> delete(
    String path, {
    bool authenticated = false,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final headers = await _buildHeaders(authenticated: authenticated);
    return _executeWithRetry(
      () => _httpClient.delete(uri, headers: headers).timeout(
            timeout ?? ApiConfig.timeout,
          ),
      authenticated: authenticated,
      retryRequest: () => _retryDelete(uri, timeout),
    );
  }

  // ---------------------------------------------------------------------------
  // Retry helpers (para despues del refresh)
  // ---------------------------------------------------------------------------

  Future<http.Response> _retryGet(Uri uri, Duration? timeout) async {
    final headers = await _buildHeaders(authenticated: true);
    return _httpClient.get(uri, headers: headers).timeout(
          timeout ?? ApiConfig.timeout,
        );
  }

  Future<http.Response> _retryPost(
      Uri uri, Map<String, dynamic>? body, Duration? timeout) async {
    final headers = await _buildHeaders(authenticated: true);
    return _httpClient
        .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(timeout ?? ApiConfig.timeout);
  }

  Future<http.Response> _retryPut(
      Uri uri, Map<String, dynamic>? body, Duration? timeout) async {
    final headers = await _buildHeaders(authenticated: true);
    return _httpClient
        .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(timeout ?? ApiConfig.timeout);
  }

  Future<http.Response> _retryDelete(Uri uri, Duration? timeout) async {
    final headers = await _buildHeaders(authenticated: true);
    return _httpClient.delete(uri, headers: headers).timeout(
          timeout ?? ApiConfig.timeout,
        );
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(ApiConfig.baseUrl);
    final fullPath = '${base.path}/$path'.replaceAll('//', '/');
    return base.replace(path: fullPath, queryParameters: queryParams);
  }

  Future<Map<String, String>> _buildHeaders({
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticated) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Ejecuta la peticion. Si el servidor responde 401 y es autenticada,
  /// intenta refrescar el token y reintenta UNA sola vez.
  Future<dynamic> _executeWithRetry(
    Future<http.Response> Function() request, {
    required bool authenticated,
    Future<http.Response> Function()? retryRequest,
  }) async {
    http.Response response;
    try {
      response = await request();
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException('Error de conexion con el servidor');
    }

    if (response.statusCode == 401 && authenticated && retryRequest != null) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        try {
          response = await retryRequest();
        } on SocketException {
          throw NetworkException();
        }
      }
    }

    return _handleResponse(response);
  }

  /// Intenta refrescar el access token usando el refresh token.
  Future<bool> _tryRefreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final uri = _buildUri('auth/refresh');
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractData(response);
        if (data is Map &&
            data['accessToken'] != null &&
            data['refreshToken'] != null) {
          await saveTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
          );
          return true;
        }
      }
    } catch (_) {
      // Refresh fallo — el usuario debera re-autenticarse.
    }

    await clearTokens();
    return false;
  }

  /// Procesa la respuesta HTTP.
  /// El backend envuelve todo en: { status, message, data, ... }
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractData(response);
    }

    // Intentar parsear el cuerpo de error del backend.
    String message = 'Error del servidor';
    dynamic errors;
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        message = body['message'] as String? ?? message;
        errors = body['errors'];
      }
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      errors: errors,
    );
  }

  /// Extrae el campo `data` del wrapper StandardResponse del backend.
  /// Si la respuesta no tiene wrapper, devuelve el body completo.
  dynamic _extractData(http.Response response) {
    if (response.body.isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded.containsKey('status') && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }
}
