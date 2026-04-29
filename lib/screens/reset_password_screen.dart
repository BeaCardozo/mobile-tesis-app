import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api.dart';
import '../services/api_client.dart';
import '../widgets/app_snack_bar.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _resetSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Api.instance.auth.resetPassword(
        token: widget.token,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() => _resetSuccess = true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        String message;
        if (e.message.toLowerCase().contains('token') ||
            e.message.toLowerCase().contains('expirado') ||
            e.message.toLowerCase().contains('invalido')) {
          message =
              'El enlace ha expirado o es invalido. Solicita uno nuevo.';
        } else if (e.message.contains('password')) {
          message =
              'La contrasena debe tener min. 8 caracteres, 1 mayuscula, 1 minuscula, 1 numero y 1 simbolo';
        } else {
          message = e.message;
        }
        AppSnackBar.error(context, message: message);
      }
    } on NetworkException {
      if (mounted) {
        AppSnackBar.error(
          context,
          message: 'Sin conexion al servidor. Verifica tu red.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          message: 'Error inesperado. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryLight,
              AppColors.white,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // Titulo
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Caracas',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: 'Ahorra',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Nueva contrasena',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Contenido principal
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: _resetSuccess
                            ? _buildSuccessContent()
                            : _buildFormContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Ingresa tu nueva contrasena.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Campo de contrasena
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Nueva contrasena',
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.primary.withOpacity(0.8),
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.grey.withOpacity(0.7),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contrasena';
              }
              if (value.length < 8) {
                return 'Minimo 8 caracteres';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Debe contener al menos una mayuscula';
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Debe contener al menos una minuscula';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Debe contener al menos un numero';
              }
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return 'Debe contener al menos un simbolo';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo de confirmar contrasena
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar contrasena',
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.primary.withOpacity(0.8),
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.grey.withOpacity(0.7),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirme su contrasena';
              }
              if (value != _passwordController.text) {
                return 'Las contrasenas no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 26),

          // Boton de restablecer
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Restablecer contrasena',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 36,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Contrasena restablecida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Ya puedes iniciar sesion con tu nueva contrasena.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _goToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Ir a iniciar sesion',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
