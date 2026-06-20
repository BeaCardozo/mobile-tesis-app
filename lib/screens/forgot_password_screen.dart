import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/app_brand_logo.dart';
import '../widgets/app_snack_bar.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Api.instance.auth.forgotPassword(_emailController.text.trim());

      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppSnackBar.error(context, message: e.message);
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
                      // Boton de volver
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.primary.withValues(alpha: 0.9),
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Titulo
                      const AppBrandLogo(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Recuperar contrasena',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey.withValues(alpha: 0.8),
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
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: _emailSent
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
            'Ingresa tu correo electronico y te enviaremos instrucciones para restablecer tu contrasena.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electronico',
              hintText: 'ejemplo@correo.com',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.primary.withValues(alpha: 0.8),
                size: 22,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withValues(alpha: 0.7),
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
            validator: Validators.email,
          ),

          const SizedBox(height: 26),

          // Boton de enviar
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
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
                      'Enviar instrucciones',
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
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Revisa tu correo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Si el correo esta registrado, recibiras un codigo de 6 digitos para restablecer tu contrasena.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(
                    email: _emailController.text.trim(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Ingresar codigo',
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
