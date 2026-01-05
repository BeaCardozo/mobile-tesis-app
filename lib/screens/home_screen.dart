import 'package:flutter/material.dart';
import 'dart:async';
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
  final PageController _promoPageController = PageController();
  int _currentPromoPage = 0;
  Timer? _promoTimer;

  // Filtros
  String? _selectedCategory;
  String? _selectedSupermarket;
  double _minPrice = 0;
  double _maxPrice = 100;
  String _sortBy = 'Relevancia';

  // Banners promocionales
  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Compara precios',
      'subtitle': 'Encuentra las mejores ofertas',
      'label': '¡Ahorra más!',
      'icon': Icons.shopping_cart_rounded,
      'gradient': [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
    },
    {
      'title': 'Ofertas del día',
      'subtitle': 'Descuentos especiales en supermercados',
      'label': 'Hoy',
      'icon': Icons.local_offer_rounded,
      'gradient': [AppColors.secondaryLight, AppColors.secondary, AppColors.primary],
    },
    {
      'title': 'Ahorra inteligente',
      'subtitle': 'Compara antes de comprar',
      'label': 'Nuevo',
      'icon': Icons.trending_down_rounded,
      'gradient': [AppColors.primary, AppColors.accent, AppColors.accentLight],
    },
  ];

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
  void initState() {
    super.initState();
    // Iniciar el timer para el carousel automático
    _startPromoTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promoPageController.dispose();
    _promoTimer?.cancel();
    super.dispose();
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPromoPage < _promoBanners.length - 1) {
        _currentPromoPage++;
      } else {
        _currentPromoPage = 0;
      }

      if (_promoPageController.hasClients) {
        _promoPageController.animateToPage(
          _currentPromoPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = null;
                            _selectedSupermarket = null;
                            _minPrice = 0;
                            _maxPrice = 100;
                            _sortBy = 'Relevancia';
                          });
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ordenar por
                        _buildFilterSection(
                          title: 'Ordenar por',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Relevancia',
                              'Precio: Menor a Mayor',
                              'Precio: Mayor a Menor',
                              'Nombre A-Z',
                            ].map((sort) {
                              final isSelected = _sortBy == sort;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = sort;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    sort,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Categoría
                        _buildFilterSection(
                          title: 'Categoría',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((category) {
                              final isSelected =
                                  _selectedCategory == category.name;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedCategory = isSelected
                                        ? null
                                        : category.name;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? category.color
                                        : AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? category.color
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.black,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Supermercado
                        _buildFilterSection(
                          title: 'Supermercado',
                          child: Column(
                            children: [
                              'Excelsior Gama',
                              'Central Madeirense',
                              'Automercado',
                              'Unicasa',
                            ].map((supermarket) {
                              final isSelected =
                                  _selectedSupermarket == supermarket;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.lightGrey,
                                  leading: Icon(
                                    Icons.store_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey,
                                  ),
                                  title: Text(
                                    supermarket,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setModalState(() {
                                      _selectedSupermarket = isSelected
                                          ? null
                                          : supermarket;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Rango de precio
                        _buildFilterSection(
                          title: 'Rango de Precio (Bs.)',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bs. ${_minPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' - ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Bs. ${_maxPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              RangeSlider(
                                values: RangeValues(_minPrice, _maxPrice),
                                min: 0,
                                max: 100,
                                divisions: 20,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.lightGrey,
                                labels: RangeLabels(
                                  'Bs. ${_minPrice.toStringAsFixed(0)}',
                                  'Bs. ${_maxPrice.toStringAsFixed(0)}',
                                ),
                                onChanged: (values) {
                                  setModalState(() {
                                    _minPrice = values.start;
                                    _maxPrice = values.end;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Aplicar filtros
                              // TODO: Filtrar productos según los criterios seleccionados
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Filtros aplicados'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Aplicar Filtros',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onPressed: _showFiltersModal,
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
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _promoPageController,
            onPageChanged: (index) {
              setState(() {
                _currentPromoPage = index;
              });
            },
            itemCount: _promoBanners.length,
            itemBuilder: (context, index) {
              final banner = _promoBanners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: (banner['gradient'] as List<Color>)
                          .map((c) => c.withOpacity(0.9))
                          .toList(),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Icono de fondo decorativo
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            banner['icon'] as IconData,
                            size: 150,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        // Contenido
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
                                child: Text(
                                  banner['label'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                banner['title'] as String,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner['subtitle'] as String,
                                style: const TextStyle(
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
                ),
              );
            },
          ),
        ),
        // Indicadores de página (dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoBanners.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPromoPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPromoPage == index
                    ? AppColors.primary
                    : AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
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
                  fontSize: 18,
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
                    SizedBox(width: 6),
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
                  fontSize: 18,
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
                    SizedBox(width: 6),
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
