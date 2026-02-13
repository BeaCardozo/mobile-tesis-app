import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final List<CartItem> _cartItems = [];

  // Productos de ejemplo - Estos vendrán del backend
  final List<Product> _allProducts = [
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
      name: 'Refresco Cola 2L',
      description: 'Bebida gaseosa sabor cola',
      imageUrl: '',
      category: 'Bebidas',
      unit: 'L',
      averagePrice: 2.00,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.85,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 2.15,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '6',
      name: 'Agua Mineral 1.5L',
      description: 'Agua mineral natural sin gas',
      imageUrl: '',
      category: 'Bebidas',
      unit: 'L',
      averagePrice: 1.20,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.10,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 1.30,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '7',
      name: 'Detergente Líquido 1L',
      description: 'Detergente multiusos para ropa',
      imageUrl: '',
      category: 'Limpieza',
      unit: 'L',
      averagePrice: 3.75,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 3.50,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 4.00,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '8',
      name: 'Shampoo Anticaspa 400ml',
      description: 'Shampoo para cabello con caspa',
      imageUrl: '',
      category: 'Cuidado Personal',
      unit: 'ml',
      averagePrice: 5.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 5.20,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 5.80,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '9',
      name: 'Alimento para Perros 2kg',
      description: 'Alimento seco para perros adultos',
      imageUrl: '',
      category: 'Mascotas',
      unit: 'kg',
      averagePrice: 8.00,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 7.50,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 8.50,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
  ];

  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts
        .where((product) => product.category == widget.category.name)
        .toList();
  }

  void _addToCart(Product product) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex >= 0) {
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
        );
      } else {
        final selectedSupermarket = product.prices.isNotEmpty
            ? product.prices.reduce((a, b) => a.price < b.price ? a : b)
            : null;

        if (selectedSupermarket != null) {
          _cartItems.add(
            CartItem(
              id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
              product: product,
              quantity: 1,
              selectedSupermarketId: selectedSupermarket.supermarketId,
              addedAt: DateTime.now(),
            ),
          );
        }
      }
    });

    AppSnackBar.success(
      context,
      message: '${product.name} agregado al carrito',
      duration: const Duration(seconds: 1),
    );
  }

  void _navigateToCart() {
    // TODO: Implementar navegación al carrito
    AppSnackBar.info(
      context,
      message: 'Navegando al carrito...',
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.category.icon,
                size: 20,
                color: widget.category.color,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CartButton(
              onTap: _navigateToCart,
              itemCount: _cartItems.fold(0, (sum, item) => sum + item.quantity),
            ),
          ),
        ],
      ),
      body: _filteredProducts.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Contador de productos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${_filteredProducts.length} productos encontrados',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grid de productos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: _filteredProducts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: _filteredProducts[index],
                                ),
                              ),
                            );
                          },
                          onAddToCart: () {
                            _addToCart(_filteredProducts[index]);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.category.icon,
                size: 64,
                color: widget.category.color.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay productos en la categoría ${widget.category.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
