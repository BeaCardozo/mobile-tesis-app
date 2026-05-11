import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'api_models.dart';

int _parseCategoryId(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

class Category {
  final int id;
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
      id: _parseCategoryId(json['id']),
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
      id: _parseCategoryId(api.id),
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
  // ─── Categorías principales (padres) ───────────────────────────────────
  'despensa': _CategoryVisual(Icons.kitchen, Color(0xFF8D6E63)),
  'alimentos frescos': _CategoryVisual(Icons.eco, Color(0xFF81C784)),
  'refrigerados y congelados': _CategoryVisual(Icons.ac_unit, Color(0xFF4FC3F7)),
  'refrigerados': _CategoryVisual(Icons.ac_unit, Color(0xFF4FC3F7)),
  'víveres': _CategoryVisual(Icons.store, Color(0xFF8D6E63)),

  // ─── Cereales, Harinas y Granos ────────────────────────────────────────
  'cereales y productos derivados': _CategoryVisual(Icons.grain, AppColors.primary),
  'arroz y granos': _CategoryVisual(Icons.grain, AppColors.primary),
  'granos': _CategoryVisual(Icons.grass, Color(0xFF8D6E63)),
  'granos: caraotas, arvejas y lentejas': _CategoryVisual(Icons.grass, Color(0xFF8D6E63)),
  'harina': _CategoryVisual(Icons.grain, Color(0xFFFF9F66)),
  'harinas': _CategoryVisual(Icons.grain, Color(0xFFFF9F66)),
  'harina de maiz precocida': _CategoryVisual(Icons.grain, Color(0xFFFF9F66)),
  'panes y cereales': _CategoryVisual(Icons.bakery_dining, Color(0xFFFFCA28)),
  'panadería': _CategoryVisual(Icons.bakery_dining, Color(0xFFFFCA28)),
  'pastas': _CategoryVisual(Icons.restaurant, Color(0xFFFF9F66)),
  'pastas alimenticias': _CategoryVisual(Icons.restaurant, Color(0xFFFF9F66)),
  'galletas, golosinas y repostería': _CategoryVisual(Icons.cookie, Color(0xFFCE93D8)),

  // ─── Aceites, Grasas y Margarinas ──────────────────────────────────────
  'aceites': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),
  'grasas y aceites': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),
  'grasas': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),
  'margarinas y aceites': _CategoryVisual(Icons.opacity, Color(0xFFFFCA28)),

  // ─── Azúcar, Sal y Café ────────────────────────────────────────────────
  'azucar': _CategoryVisual(Icons.cookie, Color(0xFFB97FB9)),
  'azúcar y sal': _CategoryVisual(Icons.cookie, Color(0xFFB97FB9)),
  'sal': _CategoryVisual(Icons.grain, Color(0xFF90A4AE)),
  'cafe': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
  'café': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
  'café y endulzantes': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),
  'café, té y otros': _CategoryVisual(Icons.coffee, Color(0xFFD4A574)),

  // ─── Salsas, Aderezos y Condimentos ────────────────────────────────────
  'salsas y aderezos': _CategoryVisual(Icons.local_dining, Color(0xFFE57373)),
  'salsas, aderezos, condimentos y sopas': _CategoryVisual(Icons.local_dining, Color(0xFFE57373)),
  'salsa y mayonesa': _CategoryVisual(Icons.local_dining, Color(0xFFE57373)),
  'mayonesas': _CategoryVisual(Icons.local_dining, Color(0xFFE57373)),

  // ─── Enlatados ─────────────────────────────────────────────────────────
  'enlatados': _CategoryVisual(Icons.inventory_2, Color(0xFF78909C)),
  'enlatados del mar': _CategoryVisual(Icons.set_meal, Color(0xFF4FC3F7)),
  'enlatados vegetales': _CategoryVisual(Icons.inventory_2, Color(0xFF81C784)),

  // ─── Lácteos, Quesos y Huevos ──────────────────────────────────────────
  'leche, quesos y huevos': _CategoryVisual(Icons.egg_alt, Color(0xFF6CB4EE)),
  'lácteos': _CategoryVisual(Icons.water_drop, Color(0xFF42A5F5)),
  'lácteos y derivados': _CategoryVisual(Icons.water_drop, Color(0xFF42A5F5)),
  'mezcla lactea': _CategoryVisual(Icons.water_drop, Color(0xFF42A5F5)),
  'quesos': _CategoryVisual(Icons.circle, Color(0xFFFFA726)),
  'huevos': _CategoryVisual(Icons.egg, Color(0xFFFFF176)),
  'yogurt': _CategoryVisual(Icons.local_cafe, Color(0xFFEC407A)),

  // ─── Carnes y Embutidos ────────────────────────────────────────────────
  'carnes': _CategoryVisual(Icons.set_meal, Color(0xFFE57373)),
  'carnes y sus preparados': _CategoryVisual(Icons.set_meal, Color(0xFFE57373)),
  'bologna/mortadela': _CategoryVisual(Icons.set_meal, Color(0xFFEF5350)),
  'jamón': _CategoryVisual(Icons.set_meal, Color(0xFFEF5350)),
  'salchichas': _CategoryVisual(Icons.set_meal, Color(0xFFAB47BC)),

  // ─── Pescados y Mariscos ───────────────────────────────────────────────
  'pescados y mariscos': _CategoryVisual(Icons.set_meal, Color(0xFF4FC3F7)),

  // ─── Frutas, Verduras y Tubérculos ─────────────────────────────────────
  'frutas y hortalizas': _CategoryVisual(Icons.eco, Color(0xFF81C784)),
  'vegetales congelados': _CategoryVisual(Icons.eco, Color(0xFF4DB6AC)),
  'raíces, tubérculos y otros': _CategoryVisual(Icons.spa, Color(0xFFA1887F)),

  // ─── Untables y Para Untar ─────────────────────────────────────────────
  'untables': _CategoryVisual(Icons.breakfast_dining, Color(0xFFFFB74D)),
  'productos para untar': _CategoryVisual(Icons.breakfast_dining, Color(0xFFFFB74D)),

  // ─── Refrigerados y Congelados ─────────────────────────────────────────
  'alimentos congelados': _CategoryVisual(Icons.ac_unit, Color(0xFF4FC3F7)),
  'alimentos refrigerados': _CategoryVisual(Icons.kitchen, Color(0xFF6CB4EE)),

  // ─── Infantil y Dietético ──────────────────────────────────────────────
  'alimento infantil': _CategoryVisual(Icons.child_care, Color(0xFF64B5F6)),
  'dietético y naturist': _CategoryVisual(Icons.spa, Color(0xFF81C784)),
};
