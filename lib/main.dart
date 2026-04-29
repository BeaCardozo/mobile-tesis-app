import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientacion de pantalla
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CaracasAhorraApp());
}

class CaracasAhorraApp extends StatefulWidget {
  const CaracasAhorraApp({super.key});

  @override
  State<CaracasAhorraApp> createState() => _CaracasAhorraAppState();
}

class _CaracasAhorraAppState extends State<CaracasAhorraApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Escuchar links cuando la app ya esta abierta (warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);

    // Manejar link que abrio la app (cold start)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      // Esperar a que el splash termine y el navigator este listo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 4), () {
          _handleDeepLink(initialUri);
        });
      });
    }
  }

  void _handleDeepLink(Uri uri) {
    // Formato: caracasahorra://reset-password?token=xxx
    if (uri.host == 'reset-password' ||
        uri.path.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(token: token),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'CaracasAhorra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
