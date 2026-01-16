import 'package:flutter/material.dart';

class AppColors {
  // Paleta de colores principal de CaracasAhorra
  static const Color primary = Color(0xFF77A14B); // Verde principal
  static const Color primaryLight = Color(0xFFBADD71); // Verde claro
  static const Color primaryDark = Color(0xFF316746); // Verde oscuro

  static const Color secondary = Color(0xFFA5C87C); // Verde secundario
  static const Color secondaryLight = Color(0xFF9AD697); // Verde menta
  static const Color secondaryDark = Color(0xFF818A49); // Verde oliva

  static const Color accent = Color(0xFF2F655E); // Verde azulado oscuro
  static const Color accentLight = Color(0xFF437D68); // Verde azulado medio

  static const Color background = Color(0xFFB1C7A1); // Fondo verde suave

  // Colores adicionales
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF77A14B);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryLight,
      primary,
      primaryDark,
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      secondaryLight,
      secondary,
    ],
  );
}
