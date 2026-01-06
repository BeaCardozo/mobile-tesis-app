import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentNavIndex = 0;
  final List<CartItem> _cartItems = [];

  // Datos de ejemplo - Estos vendrán del backend
  // TODO: Conectar con el backend para obtener los productos reales
  final List<Product> _products = [
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
    Product(
      id: '5',
      name: 'Leche Completa 1L',
      description: 'Leche entera pasteurizada',
      imageUrl: '',
      category: 'Lácteos',
      unit: 'L',
      averagePrice: 2.20,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 2.10,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 2.30,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '6',
      name: 'Pasta Primor 500g',
      description: 'Pasta larga, espagueti',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 1.80,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.70,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 1.90,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '7',
      name: 'Atún en Lata 170g',
      description: 'Atún en aceite vegetal',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'lata',
      averagePrice: 2.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 2.40,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 2.60,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '8',
      name: 'Café Instantáneo 200g',
      description: 'Café soluble premium',
      imageUrl: '',
      category: 'Bebidas',
      unit: 'kg',
      averagePrice: 5.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 5.30,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 5.70,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '9',
      name: 'Pan de Sandwich 500g',
      description: 'Pan de molde blanco',
      imageUrl: '',
      category: 'Panadería',
      unit: 'unidad',
      averagePrice: 1.20,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.15,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 1.25,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '10',
      name: 'Mayonesa 500g',
      description: 'Mayonesa tradicional',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 3.00,
      prices: [
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 2.90,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 3.10,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
  ];

  void _addToCart(Product product) {
    // Usar el primer supermercado disponible por defecto
    final defaultSupermarketId = product.prices.isNotEmpty
        ? product.prices.first.supermarketId
        : '';

    setState(() {
      // Verificar si el producto ya está en el carrito
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex != -1) {
        // Si ya existe, incrementar cantidad
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        // Si no existe, añadir nuevo item
        _cartItems.add(
          CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            product: product,
            quantity: 1,
            selectedSupermarketId: defaultSupermarketId,
            addedAt: DateTime.now(),
          ),
        );
      }
    });

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            _navigateToCart();
          },
        ),
      ),
    );
  }

  void _navigateToCart() {
    // TODO: Implementar navegación al carrito
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
        // TODO: Navegar a Categorías
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categorías'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 1),
          ),
        );
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

                    // Grid de productos
                    _buildProductsGrid(),

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
            itemCount: _cartItems.length,
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
            'Todos los Productos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_products.length} productos disponibles',
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

  Widget _buildProductsGrid() {
    return Padding(
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
            onAddToCart: () {
              _addToCart(_products[index]);
            },
          );
        },
      ),
    );
  }
}
