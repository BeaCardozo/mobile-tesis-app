import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'api_models.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final IconData icon;
  final Color color;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final visual = _categoryVisuals[name.toLowerCase()] ??
        const _CategoryVisual(Icons.category, AppColors.primary);

    return Category(
      id: json['id'].toString(),
      name: name,
      slug: json['slug'] as String? ?? '',
      icon: visual.icon,
      color: visual.color,
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  /// Convierte un ApiCategory del backend en un Category para la UI.
  factory Category.fromApi(ApiCategory api, {int productCount = 0}) {
    final visual = _resolveVisual(api.name);
    return Category(
      id: api.id,
      name: api.name,
      slug: '',
      icon: visual.icon,
      color: visual.color,
      productCount: productCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

_CategoryVisual _resolveVisual(String name) {
  return _categoryVisuals[name.toLowerCase()] ??
      const _CategoryVisual(Icons.category, AppColors.primary);
}

class _CategoryVisual {
  final IconData icon;
  final Color color;
  const _CategoryVisual(this.icon, this.color);
}

/// Mapeo visual por nombre de categoría (en minúsculas).
/// Se usa para asignar icono y color ya que el backend no los envía.
const Map<String, _CategoryVisual> _categoryVisuals = {
  // Categorías generales (padres)
  'despensa': _CategoryVisual(Icons.kitchen, Color(0xFF8D6E63)),
  'alimentos frescos': _CategoryVisual(Icons.eco, Color(0xFF81C784)),
  'refrigerados y congelados': _CategoryVisual(Icons.ac_unit, Color(0xFF4FC3F7)),

  // Subcategorías - Despensa
  'aceites': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),
  'arroz y granos': _CategoryVisual(Icons.grain, AppColors.primary),
  'azucar': _CategoryVisual(Icons.cookie, Color(0xFFB97FB9)),
  'cafe': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
  'café y endulzantes': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
  'enlatados': _CategoryVisual(Icons.inventory_2, Color(0xFF78909C)),
  'enlatados del mar': _CategoryVisual(Icons.phishing, Color(0xFF4FC3F7)),
  'harina': _CategoryVisual(Icons.grain, Color(0xFFFF9F66)),
  'pastas': _CategoryVisual(Icons.restaurant, Color(0xFFFF9F66)),
  'salsas y aderezos': _CategoryVisual(Icons.local_dining, Color(0xFFE57373)),
  'alimento infantil': _CategoryVisual(Icons.child_care, Color(0xFF64B5F6)),
  'dietético y naturist': _CategoryVisual(Icons.spa, Color(0xFF81C784)),

  // Subcategorías - Alimentos Frescos
  'panadería': _CategoryVisual(Icons.bakery_dining, Color(0xFFFFCA28)),

  // Subcategorías - Refrigerados y Congelados
  'alimentos congelados': _CategoryVisual(Icons.ac_unit, Color(0xFF4FC3F7)),
  'alimentos refrigerados': _CategoryVisual(Icons.kitchen, Color(0xFF6CB4EE)),
  'bologna/mortadela': _CategoryVisual(Icons.set_meal, Color(0xFFE57373)),
  'jamón': _CategoryVisual(Icons.set_meal, Color(0xFFEF5350)),
  'lácteos': _CategoryVisual(Icons.water_drop, Color(0xFF42A5F5)),
  'quesos': _CategoryVisual(Icons.circle, Color(0xFFFFA726)),
  'salchichas': _CategoryVisual(Icons.set_meal, Color(0xFFAB47BC)),
  'yogurt': _CategoryVisual(Icons.local_cafe, Color(0xFFEC407A)),

  // Categorías originales (compatibilidad)
  'cereales y productos derivados': _CategoryVisual(Icons.grain, AppColors.primary),
  'granos': _CategoryVisual(Icons.grass, Color(0xFF8D6E63)),
  'pastas alimenticias': _CategoryVisual(Icons.restaurant, Color(0xFFFF9F66)),
  'leche, quesos y huevos': _CategoryVisual(Icons.kitchen, Color(0xFF6CB4EE)),
  'grasas y aceites': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),
  'carnes': _CategoryVisual(Icons.set_meal, Color(0xFFE57373)),
  'pescados y mariscos': _CategoryVisual(Icons.phishing, Color(0xFF4FC3F7)),
  'frutas y hortalizas': _CategoryVisual(Icons.eco, Color(0xFF81C784)),
  'raíces, tubérculos y otros': _CategoryVisual(Icons.spa, Color(0xFFA1887F)),
  'azúcar y sal': _CategoryVisual(Icons.cookie, Color(0xFFB97FB9)),
  'café, té y otros': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
};
