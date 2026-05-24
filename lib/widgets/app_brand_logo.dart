import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Logo de texto "CaracasAhorra" en dos colores.
/// Usado en splash, login, register, headers y otras pantallas.
class AppBrandLogo extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final double? letterSpacing;

  const AppBrandLogo({
    super.key,
    this.fontSize = 22,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = -0.3,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Caracas',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: AppColors.primary,
              letterSpacing: letterSpacing,
            ),
          ),
          TextSpan(
            text: 'Ahorra',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: AppColors.accent,
              letterSpacing: letterSpacing,
            ),
          ),
        ],
      ),
    );
  }
}
