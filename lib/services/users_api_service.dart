import '../models/api_models.dart';
import 'api_client.dart';

/// Servicio para los endpoints de usuario (autenticado).
/// GET/PUT /api/users/*
class UsersApiService {
  final ApiClient _client;

  UsersApiService(this._client);

  /// Obtener perfil del usuario autenticado.
  /// GET /api/users/me
  Future<UserProfile> getMe() async {
    final data = await _client.get('users/me', authenticated: true);
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  /// Actualizar nombre y email del usuario.
  /// PUT /api/users/me
  Future<void> updateMe({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (email != null) body['email'] = email;

    await _client.put(
      'users/me',
      body: body,
      authenticated: true,
    );
  }

  /// Cambiar contrasena.
  /// PUT /api/users/me/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put(
      'users/me/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      authenticated: true,
    );
  }

  /// Actualizar preferencias (moneda, idioma).
  /// PUT /api/users/me/preferences
  Future<void> updatePreferences({
    String? currency,
    String? language,
  }) async {
    final body = <String, dynamic>{};
    if (currency != null) body['currency'] = currency;
    if (language != null) body['language'] = language;

    await _client.put(
      'users/me/preferences',
      body: body,
      authenticated: true,
    );
  }
}
