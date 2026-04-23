import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api.dart';
import '../services/cart_manager.dart';
import '../widgets/product_card.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  final String currency;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    this.currency = 'Bs',
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    CartManager.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProducts() async {
    try {
      final paginated = await Api.instance.products.list(
        categoryId: widget.category.id,
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _filteredProducts = paginated.items
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
          message: 'Error al cargar productos',
        );
      }
    }
  }

  void _addToCart(Product product) {
    CartManager.instance.addItem(product);
    AppSnackBar.success(
      context,
      message: '${product.name} agregado al carrito',
      duration: const Duration(seconds: 1),
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
              itemCount: CartManager.instance.itemCount,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _filteredProducts.isEmpty
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
                          currency: widget.currency,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: _filteredProducts[index],
                                  currency: widget.currency,
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
