import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Para emulador Android usar 10.0.2.2, para iOS simulador/dispositivo usar localhost
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4003/api';
    }
    return 'http://localhost:4003/api';
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return _extractData(body);
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(body),
    );
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return _extractData(body);
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(body),
    );
  }

  static Future<Map<String, dynamic>> getMe(String accessToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return _extractData(body);
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(body),
    );
  }

  static Future<Map<String, dynamic>> refreshTokens(
      String refreshToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return _extractData(body);
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(body),
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (currentPassword != null) data['currentPassword'] = currentPassword;
    if (newPassword != null) data['newPassword'] = newPassword;

    final response = await http.patch(
      Uri.parse('$_baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return _extractData(body);
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(body),
    );
  }

  static Future<void> logout(String accessToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 201) {
      // No lanzar error en logout, solo loguear silenciosamente
    }
  }

  /// Extrae el campo `data` de la respuesta envuelta por el interceptor del backend.
  /// El backend retorna: { status, message, data: { ... } }
  static Map<String, dynamic> _extractData(Map<String, dynamic> body) {
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  static String _extractErrorMessage(Map<String, dynamic> body) {
    if (body.containsKey('message')) {
      final message = body['message'];
      if (message is List) {
        return message.join(', ');
      }
      return message.toString();
    }
    return 'Error desconocido';
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
