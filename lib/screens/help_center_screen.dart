import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección FAQ
                    _buildSectionTitle('Preguntas Frecuentes'),
                    const SizedBox(height: 12),
                    _buildFaqCategory(
                      title: 'Cuenta',
                      icon: Icons.person_outline_rounded,
                      iconColor: AppColors.primary,
                      questions: const [
                        _FaqItem(
                          question: '¿Cómo cambio mi contraseña?',
                          answer:
                              'Puedes cambiar tu contraseña desde la sección "Editar Perfil" en tu perfil. Ingresa tu contraseña actual y luego la nueva contraseña. Esta funcionalidad estará completamente disponible próximamente.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFaqCategory(
                      title: 'Comparación de Precios',
                      icon: Icons.compare_arrows_rounded,
                      iconColor: const Color(0xFF5B9BD5),
                      questions: const [
                        _FaqItem(
                          question: '¿De dónde provienen los precios?',
                          answer:
                              'Los precios son recopilados directamente de los principales supermercados de Caracas. Nuestro equipo se encarga de verificar y actualizar la información periódicamente para garantizar su precisión.',
                        ),
                        _FaqItem(
                          question: '¿Cada cuánto se actualizan los precios?',
                          answer:
                              'Los precios se actualizan diariamente.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFaqCategory(
                      title: 'Carrito',
                      icon: Icons.shopping_cart_outlined,
                      iconColor: AppColors.accent,
                      questions: const [
                        _FaqItem(
                          question: '¿Cómo funciona el carrito inteligente?',
                          answer:
                              'El carrito inteligente analiza los productos que agregas y te muestra en qué supermercado puedes obtener el mejor precio total.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFaqCategory(
                      title: 'General',
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFFED7D95),
                      questions: const [
                        _FaqItem(
                          question: '¿La app es gratuita?',
                          answer:
                              'Sí, CaracasAhorra es completamente gratuita. Nuestro objetivo es ayudar a los caraqueños a encontrar los mejores precios sin costo alguno.',
                        ),
                        _FaqItem(
                          question:
                              '¿En qué zonas de Caracas está disponible?',
                          answer:
                              'Actualmente cubrimos los principales supermercados del Área Metropolitana de Caracas.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Sección Contacto
                    _buildSectionTitle('Contáctanos'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildContactItem(
                            icon: Icons.email_outlined,
                            title: 'Correo de soporte',
                            subtitle: 'soporte@caracasahorra.com',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Expanded(
                child: Text(
                  'Centro de Ayuda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildFaqCategory({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_FaqItem> questions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          children: questions.map((faq) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    faq.question,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black.withOpacity(0.8),
                    ),
                  ),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  children: [
                    Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
