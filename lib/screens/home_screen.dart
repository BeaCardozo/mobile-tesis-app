import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api.dart';
import '../services/cart_manager.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'category_detail_screen.dart';
import 'featured_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoPageController = PageController();
  int _currentPromoPage = 0;
  Timer? _promoTimer;

  // Moneda seleccionada
  String _selectedCurrency = 'Bs';

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

  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startPromoTimer();
    _loadData();
    CartManager.instance.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        Api.instance.categories.listAll(),
        Api.instance.products.featured(),
      ]);

      final apiCategories = results[0] as List;
      final apiProducts = results[1] as List;

      if (mounted) {
        setState(() {
          _categories = apiCategories
              .map((c) => Category.fromApi(c, productCount: c.productCount))
              .where((c) => c.productCount > 0)
              .take(8)
              .toList();
          _products = apiProducts
              .map((p) => Product.fromApiSummary(p))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.error(
          context,
          message: 'Error al cargar datos. Verifica tu conexión.',
        );
      }
    }
  }

  @override
  void dispose() {
    CartManager.instance.removeListener(_onCartChanged);
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

  void _addToCart(Product product) {
    CartManager.instance.addItem(product);
    AppSnackBar.success(
      context,
      message: '${product.name} añadido al carrito',
      actionLabel: 'Ver carrito',
      onAction: _navigateToCart,
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
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
            AppHeader(
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: (newValue) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              },
              onCartTap: _navigateToCart,
              cartItemCount: CartManager.instance.itemCount,
            ),

            // Contenido con scroll
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

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
    );
  }

  Widget _buildPromoBanner() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            clipBehavior: Clip.none,
            controller: _promoPageController,
            onPageChanged: (index) {
              setState(() {
                _currentPromoPage = index;
              });
            },
            itemCount: _promoBanners.length,
            itemBuilder: (context, index) {
              final banner = _promoBanners[index];
              final gradientColors = banner['gradient'] as List<Color>;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[1].withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Círculos decorativos de fondo
                        Positioned(
                          right: -40,
                          top: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: -50,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          bottom: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),

                        // Contenido
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: [
                              // Texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        banner['label'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      banner['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      banner['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.85),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Icono
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 28,
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
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPromoPage == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPromoPage == index
                    ? AppColors.primary
                    : AppColors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 96,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CategoryCard(
                    category: _categories[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailScreen(
                            category: _categories[index],
                            currency: _selectedCurrency,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeaturedProductsScreen(
                        products: _products,
                        currency: _selectedCurrency,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
                currency: _selectedCurrency,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: _products[index],
                        currency: _selectedCurrency,
                      ),
                    ),
                  );
                },
                onAddToCart: () {
                  _addToCart(_products[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
