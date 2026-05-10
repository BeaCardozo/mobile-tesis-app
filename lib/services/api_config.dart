class ApiConfig {
  /// URL base del backend (ca-api).
  /// En desarrollo local con emulador Android usa 10.0.2.2,
  /// en iOS simulador o web usa localhost.
  /// Cambiar a la URL de produccion cuando se despliegue.
  static const String baseUrl = 'http://localhost:4003/api';

  /// Timeout para peticiones normales (ms).
  static const Duration timeout = Duration(seconds: 15);

  /// Timeout para peticiones de carga pesada (comparacion de carrito, etc.).
  static const Duration longTimeout = Duration(seconds: 30);
}
