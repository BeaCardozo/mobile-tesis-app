import 'dart:math';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animaciones del logo
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;

  // Animaciones de monedas (4 monedas escalonadas)
  late List<Animation<double>> _coinFalls;
  late List<Animation<double>> _coinOpacities;
  late List<Animation<double>> _coinScales;

  // Animaciones de texto
  late Animation<double> _brandOpacity;
  late Animation<Offset> _brandSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _loaderOpacity;
  late Animation<double> _fadeOut;

  // Posiciones horizontales de cada moneda (relativas al centro)
  final List<double> _coinOffsets = [-18, 12, -6, 20];
  // Posiciones iniciales Y de cada moneda (desde arriba)
  final List<double> _coinStartY = [-65, -75, -55, -70];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // Logo: scale + fade (0% - 22%)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );

    // Glow: aparece suave (10% - 30%)
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.30, curve: Curves.easeOut),
      ),
    );

    // Monedas: cada una cae escalonada después de que aparece el logo
    _coinFalls = [];
    _coinOpacities = [];
    _coinScales = [];
    for (int i = 0; i < 4; i++) {
      final start = 0.18 + (i * 0.07); // 18%, 25%, 32%, 39%
      final end = start + 0.14; // cada una dura 14% del timeline

      _coinFalls.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        ),
      );
      _coinOpacities.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 45),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end),
          ),
        ),
      );
      _coinScales.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 30),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end),
          ),
        ),
      );
    }

    // Brand name: fade + slide up (38% - 56%)
    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.56, curve: Curves.easeOut),
      ),
    );
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.56, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline: fade in (50% - 65%)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
      ),
    );

    // Loader: fade in (58% - 70%)
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.70, curve: Curves.easeOut),
      ),
    );

    // Fade out al final (84% - 100%)
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.84, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    bool isAuthenticated = false;

    final accessToken = await AuthService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        // Validar que el token sigue siendo válido
        final userData = await ApiService.getMe(accessToken);
        // Actualizar datos locales por si cambiaron
        await AuthService.updateUserName(userData['name'] ?? '');
        isAuthenticated = true;
      } catch (_) {
        // Token expirado, intentar refresh
        try {
          final refreshToken = await AuthService.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            final tokens = await ApiService.refreshTokens(refreshToken);
            await AuthService.saveTokens(
              accessToken: tokens['accessToken'],
              refreshToken: tokens['refreshToken'],
            );
            isAuthenticated = true;
          }
        } catch (_) {
          // Refresh también falló, limpiar sesión
          await AuthService.logout();
        }
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isAuthenticated ? const MainScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCoin(int index) {
    final dx = _coinOffsets[index];
    final startY = _coinStartY[index];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final fall = _coinFalls[index].value;
        final opacity = _coinOpacities[index].value;
        final scale = _coinScales[index].value;

        // La moneda cae desde startY hasta ~+5 (entra en la alcancía)
        final currentY = startY + ((-startY + 5) * fall);
        // Leve movimiento horizontal sinusoidal mientras cae
        final sway = sin(fall * pi) * 4;

        return Positioned(
          top: 70 + currentY, // 70 = centro aproximado del icon area
          left: 75 + dx + sway, // 75 = centro horizontal del area
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFF8F00),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA726).withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0F5EC),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo con monedas
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Glow suave detrás
                            FadeTransition(
                              opacity: _glowOpacity,
                              child: Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.12),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Icono de la alcancía con gradiente
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ).createShader(bounds),
                              child: const Icon(
                                Icons.savings_rounded,
                                color: Colors.white,
                                size: 88,
                              ),
                            ),

                            // Monedas cayendo
                            _buildCoin(0),
                            _buildCoin(1),
                            _buildCoin(2),
                            _buildCoin(3),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Nombre de la app
                  SlideTransition(
                    position: _brandSlide,
                    child: FadeTransition(
                      opacity: _brandOpacity,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Caracas',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Ahorra',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Compara precios, ahorra más',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey.withOpacity(0.7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loader sutil
                  FadeTransition(
                    opacity: _loaderOpacity,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withOpacity(0.4),
                        ),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
