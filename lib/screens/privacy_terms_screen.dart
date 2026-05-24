import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

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
                    _buildSection(
                      title: 'Términos de Uso',
                      icon: Icons.description_outlined,
                      iconColor: AppColors.primary,
                      content: '''
Al utilizar CaracasAhorra, aceptas los siguientes términos:

1. Uso Aceptable
CaracasAhorra es una plataforma diseñada para ayudar a los consumidores a comparar precios de productos en supermercados de Caracas. Te comprometes a usar la aplicación únicamente con fines personales y no comerciales. Queda prohibido el uso automatizado, la extracción masiva de datos o cualquier actividad que pueda afectar el rendimiento del servicio.

2. Propiedad Intelectual
Todo el contenido de CaracasAhorra, incluyendo pero no limitado a textos, gráficos, logotipos, iconos, imágenes, y software, es propiedad de CaracasAhorra o sus licenciantes y está protegido por las leyes de propiedad intelectual aplicables.

3. Precisión de la Información
Los precios mostrados en la aplicación son referenciales y pueden variar. CaracasAhorra no garantiza la exactitud absoluta de los precios publicados, ya que estos dependen de la información proporcionada por los establecimientos comerciales y pueden cambiar sin previo aviso.

4. Modificaciones
Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor inmediatamente después de su publicación en la aplicación. El uso continuado del servicio después de cualquier modificación constituye la aceptación de los nuevos términos.''',
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Política de Privacidad',
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.iconPink,
                      content: '''
Tu privacidad es importante para nosotros. Esta política describe cómo recopilamos, usamos y protegemos tu información.

1. Datos que Recopilamos
- Información de registro: nombre, correo electrónico y contraseña (encriptada).
- Datos de uso: productos consultados, búsquedas realizadas y productos agregados al carrito.
- Información del dispositivo: modelo, sistema operativo y versión de la aplicación.

2. Cómo Usamos tus Datos
- Para proporcionarte el servicio de comparación de precios personalizado.
- Para mejorar la experiencia del usuario y la funcionalidad de la aplicación.
- Para enviarte notificaciones sobre ofertas relevantes (solo si lo autorizas).
- Para generar estadísticas anónimas que nos ayuden a mejorar el servicio.

3. Protección de Datos
Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal contra acceso no autorizado, pérdida o alteración. Las contraseñas se almacenan encriptadas y las comunicaciones se realizan a través de conexiones seguras.

4. Compartir Información
No vendemos, comercializamos ni transferimos tu información personal a terceros. La información puede compartirse únicamente con proveedores de servicios que nos ayudan a operar la aplicación, siempre bajo estrictos acuerdos de confidencialidad.''',
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Almacenamiento Local',
                      icon: Icons.storage_outlined,
                      iconColor: AppColors.iconBlue,
                      content: '''
CaracasAhorra utiliza almacenamiento local en tu dispositivo para:

- Mantener tu sesión iniciada: Guardamos tokens de autenticación de forma segura para que no tengas que iniciar sesión cada vez que abras la aplicación.
- Preferencias del usuario: Almacenamos tus preferencias de configuración, como nombre y correo, para personalizar tu experiencia.
- Datos del carrito: Tu carrito de compras se guarda localmente para que no pierdas tus selecciones.

Estos datos se almacenan exclusivamente en tu dispositivo y puedes eliminarlos en cualquier momento cerrando sesión o desinstalando la aplicación.''',
                    ),

                    const SizedBox(height: 24),

                    // Fecha de última actualización
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Última actualización: Febrero 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                  'Privacidad y Términos',
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
