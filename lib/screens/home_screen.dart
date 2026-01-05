import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo - Estos vendrán del backend
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
  ];

  // Productos de ejemplo - Estos vendrán del backend
  List<Product> _products = [
    Product(
      id: '1',
      name: 'Arroz Diana 1kg',
      description: 'Arroz blanco de grano largo, calidad premium',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 3.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 3.20,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 3.45,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 3.80,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '2',
      name: 'Aceite Mazeite 1L',
      description: 'Aceite vegetal 100% puro',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'L',
      averagePrice: 4.25,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 4.10,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 4.40,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '3',
      name: 'Harina PAN 1kg',
      description: 'Harina de maíz precocida',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 2.80,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 2.65,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 2.95,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '4',
      name: 'Azúcar Blanca 1kg',
      description: 'Azúcar refinada',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 1.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.45,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 1.55,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String productId) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          isFavorite: !_products[index].isFavorite,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),

                    const SizedBox(height: 16),

                    // Ubicación
                    _buildLocationSection(),

                    const SizedBox(height: 16),

                    // Barra de búsqueda
                    _buildSearchBar(),

                    const SizedBox(height: 20),

                    // Banner promocional
                    _buildPromoBanner(),

                    const SizedBox(height: 24),

                    // Categorías
                    _buildCategoriesSection(),

                    const SizedBox(height: 24),

                    // Productos destacados
                    _buildFeaturedProducts(),

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
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // TODO: Implementar navegación a otras pantallas
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Caracas',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: 'Ahorra',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      'VE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caracas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Venezuela',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(
              color: AppColors.grey.withOpacity(0.6),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.grey,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.mic,
                color: AppColors.primary,
              ),
              onPressed: () {
                // TODO: Implementar búsqueda por voz
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onSubmitted: (value) {
            // TODO: Implementar búsqueda
          },
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight.withOpacity(0.8),
              AppColors.secondaryLight.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.shopping_cart_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '¡Ahorra más!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Compara precios',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Encuentra las mejores ofertas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Ver todas las categorías
                },
                child: const Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return CategoryCard(
                category: _categories[index],
                onTap: () {
                  // TODO: Navegar a productos por categoría
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Productos Destacados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Ver todos los productos
                },
                child: const Row(
                  children: [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: _products[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: _products[index],
                      ),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  _toggleFavorite(_products[index].id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
