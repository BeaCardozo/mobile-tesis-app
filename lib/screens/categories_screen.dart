import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/cart_button.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _currentNavIndex = 1; // Índice 1 = Categorías

  // Datos de ejemplo - Estos vendrán del backend
  // TODO: Conectar con el backend para obtener las categorías reales
  final List<Category> _categories = [
    Category(
      id: '1',
      name: 'Alimentos',
      icon: Icons.restaurant,
      color: AppColors.primary,
    ),
    Category(
      id: '2',
      name: 'Bebidas',
      icon: Icons.local_drink,
      color: const Color(0xFF5B9BD5),
    ),
    Category(
      id: '3',
      name: 'Limpieza',
      icon: Icons.cleaning_services,
      color: const Color(0xFFB97FB9),
    ),
    Category(
      id: '4',
      name: 'Cuidado Personal',
      icon: Icons.self_improvement,
      color: const Color(0xFFED7D95),
    ),
    Category(
      id: '5',
      name: 'Mascotas',
      icon: Icons.pets,
      color: AppColors.accent,
    ),
    Category(
      id: '6',
      name: 'Snacks',
      icon: Icons.cookie,
      color: const Color(0xFFFF9F66),
    ),
    Category(
      id: '7',
      name: 'Panadería',
      icon: Icons.bakery_dining,
      color: const Color(0xFFD4A574),
    ),
    Category(
      id: '8',
      name: 'Lácteos',
      icon: Icons.kitchen,
      color: const Color(0xFF6CB4EE),
    ),
    Category(
      id: '9',
      name: 'Carnes',
      icon: Icons.set_meal,
      color: const Color(0xFFE57373),
    ),
    Category(
      id: '10',
      name: 'Frutas y Verduras',
      icon: Icons.eco,
      color: const Color(0xFF81C784),
    ),
    Category(
      id: '11',
      name: 'Congelados',
      icon: Icons.ac_unit,
      color: const Color(0xFF64B5F6),
    ),
    Category(
      id: '12',
      name: 'Bebé',
      icon: Icons.child_care,
      color: const Color(0xFFFFB6C1),
    ),
  ];

  void _navigateToCart() {
    // TODO: Implementar navegación al carrito
    // Por ahora solo mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando al carrito...'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onNavBarTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
    });

    // Navegación según el índice
    switch (index) {
      case 0:
        // Volver a Home
        Navigator.pop(context);
        break;
      case 1:
        // Ya estamos en Categorías
        break;
      case 2:
        // TODO: Navegar a Ofertas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ofertas - Próximamente'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 3:
        // TODO: Navegar a Notificaciones
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificaciones - Próximamente'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 4:
        // TODO: Navegar a Perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil - Próximamente'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header fijo
            _buildHeader(),

            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Título y contador
                    _buildTitleSection(),

                    const SizedBox(height: 20),

                    // Grid de categorías
                    _buildCategoriesGrid(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de volver
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.black,
              ),
            ),
          ),

          // Logo
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Caracas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: 'Ahorra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Botón del carrito
          CartButton(
            onTap: _navigateToCart,
            itemCount: 0, // TODO: Conectar con el carrito real
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todas las Categorías',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_categories.length} categorías disponibles',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryGridCard(
            category: _categories[index],
            onTap: () {
              // TODO: Navegar a productos por categoría
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Navegando a ${_categories[index].name}...',
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryGridCard({
    required Category category,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 42,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
