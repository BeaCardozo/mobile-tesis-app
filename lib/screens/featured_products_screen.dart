import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';

class FeaturedProductsScreen extends StatefulWidget {
  final List<Product> products;
  final String currency;

  const FeaturedProductsScreen({
    super.key,
    required this.products,
    this.currency = 'Bs',
  });

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  final List<CartItem> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      // Buscar si el producto ya existe en el carrito
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex >= 0) {
        // Si existe, incrementar cantidad usando copyWith
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
        );
      } else {
        // Si no existe, agregar nuevo item
        // Seleccionar el supermercado con el precio más bajo por defecto
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

    // Mostrar feedback al usuario
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
        title: RichText(
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Título y contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos Destacados',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.products.length} productos disponibles',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid de productos
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
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: widget.products[index],
                    currency: widget.currency,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: widget.products[index],
                            currency: widget.currency,
                          ),
                        ),
                      );
                    },
                    onAddToCart: () {
                      _addToCart(widget.products[index]);
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
}
