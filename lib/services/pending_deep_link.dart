/// Buffer estático para un deep link recibido en cold start.
/// El splash lo consume justo antes de navegar, evitando timers arbitrarios.
class PendingDeepLink {
  static Uri? _uri;

  static void set(Uri uri) => _uri = uri;

  static Uri? consume() {
    final u = _uri;
    _uri = null;
    return u;
  }
}
