import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Usuario';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await AuthService.getUserEmail();
    final name = await AuthService.getUserName();

    setState(() {
      _userEmail = email ?? 'usuario@ejemplo.com';
      _userName = name ?? 'Usuario';
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppColors.lightGrey,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.lightGrey,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Título
                    const Text(
                      'Mi Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nombre del usuario
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email del usuario
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección: Mi Cuenta
              _buildSection(
                title: 'Mi Cuenta',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Editar Perfil',
                    subtitle: 'Actualiza tu información personal',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Editar Perfil');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Direcciones',
                    subtitle: 'Gestiona tus direcciones de entrega',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Direcciones');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.payment_rounded,
                    title: 'Métodos de Pago',
                    subtitle: 'Administra tus métodos de pago',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Métodos de Pago');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sección: Preferencias
              _buildSection(
                title: 'Preferencias',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Configura tus notificaciones',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Notificaciones');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.language_rounded,
                    title: 'Idioma',
                    subtitle: 'Español',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Idioma');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.attach_money_rounded,
                    title: 'Moneda Preferida',
                    subtitle: 'Bolívares (Bs)',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Moneda Preferida');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sección: Soporte
              _buildSection(
                title: 'Soporte',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Centro de Ayuda',
                    subtitle: 'Encuentra respuestas a tus preguntas',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Centro de Ayuda');
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Acerca de',
                    subtitle: 'Información sobre CaracasAhorra',
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacidad y Términos',
                    subtitle: 'Lee nuestras políticas',
                    onTap: () {
                      // TODO: Implementar cuando esté el backend
                      _showComingSoonSnackBar('Privacidad y Términos');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botón de Cerrar Sesión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Versión de la app
              Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'CaracasAhorra',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'CaracasAhorra es tu aplicación de confianza para comparar precios de productos en supermercados de Caracas y encontrar las mejores ofertas.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 CaracasAhorra. Todos los derechos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
