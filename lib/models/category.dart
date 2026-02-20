import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class Category {
  final int id;
  final String name;
  final String slug;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final visual = _categoryVisuals[name.toLowerCase()] ??
        const _CategoryVisual(Icons.category, AppColors.primary);

    return Category(
      id: json['id'] as int,
      name: name,
      slug: json['slug'] as String? ?? '',
      icon: visual.icon,
      color: visual.color,
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

class _CategoryVisual {
  final IconData icon;
  final Color color;
  const _CategoryVisual(this.icon, this.color);
}

/// Mapeo visual por nombre de categoría (en minúsculas).
/// Se usa para asignar icono y color ya que el backend no los envía.
const Map<String, _CategoryVisual> _categoryVisuals = {
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
