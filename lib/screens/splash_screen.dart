import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _caracasController;
  late AnimationController _ahorraController;
  late Animation<Offset> _caracasSlideAnimation;
  late Animation<Offset> _ahorraSlideAnimation;

  bool _showGreenBackground = false;
  bool _showWhiteText = false;
  bool _showLoadingIndicator = false;

  @override
  void initState() {
    super.initState();

    // Controlador para la palabra "Caracas" (desde arriba)
    _caracasController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controlador para la palabra "Ahorra" (desde abajo)
    _ahorraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animación de slide para "Caracas" (desde la izquierda)
    _caracasSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _caracasController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animación de slide para "Ahorra" (desde la derecha)
    _ahorraSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ahorraController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Secuencia de animaciones
    _startAnimationSequence();

    // Navegar a la pantalla principal después de las animaciones
    Timer(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        // Verificar si el usuario está autenticado
        final isLoggedIn = await AuthService.isLoggedIn();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  isLoggedIn ? const MainScreen() : const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      }
    });
  }

  void _startAnimationSequence() async {
    // Iniciar animación de "Caracas" inmediatamente
    _caracasController.forward();

    // Iniciar animación de "Ahorra" con un pequeño delay
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _ahorraController.forward();
    }

    // Después de que ambas palabras estén en posición, cambiar fondo, texto y mostrar loading
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _showGreenBackground = true;
        _showWhiteText = true;
        _showLoadingIndicator = true;
      });
    }
  }

  @override
  void dispose() {
    _caracasController.dispose();
    _ahorraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _showGreenBackground
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.white,
                    AppColors.white,
                  ],
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Palabra "Caracas" entrando desde la izquierda
              SlideTransition(
                position: _caracasSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: _showWhiteText ? AppColors.white : AppColors.primary,
                      letterSpacing: 1.5,
                      height: 1.0,
                      shadows: _showWhiteText
                          ? [
                              const Shadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: const Text('Caracas'),
                  ),
                ),
              ),

              // Palabra "Ahorra" entrando desde la derecha
              SlideTransition(
                position: _ahorraSlideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: _showWhiteText ? AppColors.white : AppColors.primaryDark,
                      letterSpacing: 1.5,
                      height: 1.0,
                      shadows: _showWhiteText
                          ? [
                              const Shadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: const Text('Ahorra'),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Indicador de carga que aparece cuando el fondo se pone verde
              AnimatedOpacity(
                opacity: _showLoadingIndicator ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
