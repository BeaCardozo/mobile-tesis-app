class ApiConfig {
  /// URL base del backend (ca-api).
  ///
  /// Se configura en tiempo de build con `--dart-define=API_BASE_URL=...`.
  /// Si no se provee, usa localhost para desarrollo.
  ///
  /// Ejemplos:
  ///   Local PC / iOS simulador: http://localhost:4003/api
  ///   Emulador Android:        http://10.0.2.2:4003/api
  ///   Teléfono en LAN:         http://192.168.x.x:4003/api
  ///   Producción:              https://api.caracasahorra.com/api
  ///
  /// Uso:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4003/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.180:4003/api',
  );

  /// Timeout para peticiones normales (ms).
  static const Duration timeout = Duration(seconds: 15);

  /// Timeout para peticiones de carga pesada (comparacion de carrito, etc.).
  static const Duration longTimeout = Duration(seconds: 30);
}
