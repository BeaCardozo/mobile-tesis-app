import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Constructor para facilitar la conversión desde JSON cuando se implemente el backend
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: Icons.category, // Por defecto, el backend podría enviar el nombre del icono
      color: Color(int.parse(json['color'] as String)),
    );
  }

  // Método para convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value.toString(),
    };
  }
}
