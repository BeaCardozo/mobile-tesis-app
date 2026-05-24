import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/app_brand_logo.dart';
import '../widgets/app_snack_bar.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;


    setState(() => _isLoading = true);

    try {
      // Separar nombre completo en firstName y lastName
      final fullName = _nameController.text.trim();
      final parts = fullName.split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await Api.instance.auth.register(
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Login automatico tras registro exitoso
      await Api.instance.auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: false,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );

        AppSnackBar.success(
          context,
          message: 'Registro exitoso - Bienvenido a CaracasAhorra',
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        String message;
        if (e.statusCode == 409 || e.message.toLowerCase().contains('unique')) {
          message = 'Este correo ya está registrado';
        } else if (e.message.contains('password')) {
          message =
              'La contraseña debe tener mín. 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 símbolo';
        } else {
          message = e.message;
        }
        AppSnackBar.error(context, message: message);
      }
    } on NetworkException {
      if (mounted) {
        AppSnackBar.error(
          context,
          message: 'Sin conexión al servidor. Verifica tu red.',
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
                      // Botón de volver
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

                      // Título
                      const AppBrandLogo(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Crear cuenta nueva',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Formulario
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Campo de nombre
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: 'Nombre completo',
                                  hintText: 'Juan Pérez',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su nombre';
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Campo de email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
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

                              const SizedBox(height: 16),

                              // Campo de contraseña
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  hintText: '••••••••',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.grey.withValues(alpha: 0.7),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
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
                                validator: Validators.password,
                              ),

                              const SizedBox(height: 16),

                              // Campo de confirmar contraseña
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirmar contraseña',
                                  hintText: '••••••••',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.grey.withValues(alpha: 0.7),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
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
                                validator: (value) => Validators.matchesPassword(
                                  value,
                                  _passwordController.text,
                                ),
                              ),

                              const SizedBox(height: 26),

                              // Botón de registro
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                        AppColors.primary.withValues(alpha: 0.6),
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
                                          'Registrarse',
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
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Ya tienes cuenta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Inicia sesión',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
}
