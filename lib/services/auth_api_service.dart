import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de autenticacion (POST /api/auth/*).
class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  /// Registrar un nuevo usuario.
  /// POST /api/auth/register
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await _client.post('auth/register', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
  }

  /// Iniciar sesion. Guarda los tokens automaticamente.
  /// Si [rememberMe] es true, la sesion persiste entre reinicios de la app.
  /// POST /api/auth/login
  Future<AuthTokens> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final data = await _client.post('auth/login', body: {
      'email': email,
      'password': password,
    });
    final tokens = AuthTokens.fromJson(data as Map<String, dynamic>);
    await _client.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _client.saveRememberMe(rememberMe, email: email);
    return tokens;
  }

  /// Obtener el perfil del usuario autenticado.
  /// GET /api/auth/me
  Future<UserProfile> getMe() async {
    final data = await _client.get('auth/me', authenticated: true);
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  /// Cerrar sesion. Limpia los tokens locales.
  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      await _client.post('auth/logout', authenticated: true);
    } catch (_) {
      // Si falla (token expirado, etc.), igual limpiamos localmente.
    }
    await _client.clearTokens();
  }

  /// Solicitar restablecimiento de contrasena.
  /// POST /api/auth/forgot-password
  Future<String> forgotPassword(String email) async {
    final data = await _client.post('auth/forgot-password', body: {
      'email': email,
    });
    if (data is Map) {
      return data['message'] as String? ?? 'Solicitud enviada';
    }
    return 'Solicitud enviada';
  }

  /// Restablecer contrasena con token.
  /// POST /api/auth/reset-password
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _client.post('auth/reset-password', body: {
      'token': token,
      'password': password,
    });
  }

  /// Verificar si hay una sesion activa (token guardado localmente).
  Future<bool> hasSession() async {
    final token = await _client.getAccessToken();
    return token != null;
  }
}
