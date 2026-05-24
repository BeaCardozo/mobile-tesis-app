import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/cart_item.dart';
import '../models/api_models.dart';
import '../services/cart_manager.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/product_image.dart';
import '../services/api.dart';
import 'cart_comparison_screen.dart';

class CartScreen extends StatefulWidget {
  final String currency;

  const CartScreen({super.key, this.currency = 'Bs'});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double? _apiFxRate;

  @override
  void initState() {
    super.initState();
    CartManager.instance.addListener(_onCartChanged);
    _loadFxRate();
  }

  Future<void> _loadFxRate() async {
    final r = await Api.instance.meta.fxUsdToBs();
    if (!mounted) return;
    setState(() => _apiFxRate = r);
  }

  @override
  void dispose() {
    CartManager.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  List<CartItem> get _cartItems => CartManager.instance.items;

  double get _exchangeRate {
    for (final item in _cartItems) {
      if (item.priceUsd > 0 && item.price > 0) {
        return item.price / item.priceUsd;
      }
    }
    if (_apiFxRate != null && _apiFxRate! > 0) return _apiFxRate!;
    return 0;
  }

  void _navigateToComparison() {
    final cartId = CartManager.instance.activeCartId;
    if (cartId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartComparisonScreen(
          cartId: cartId,
          currency: widget.currency,
          exchangeRate: _exchangeRate,
          itemCount: _cartItems.length,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Gestión de carritos
  // ---------------------------------------------------------------------------

  void _showCartSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartSelectorSheet(
        carts: CartManager.instance.allCarts,
        activeCartId: CartManager.instance.activeCartId,
        onSelectCart: (cartId) async {
          Navigator.pop(context);
          await CartManager.instance.switchCart(cartId);
        },
        onCreateCart: () {
          Navigator.pop(context);
          _showCreateCartDialog();
        },
        onDeleteCart: (cart) {
          Navigator.pop(context);
          _showDeleteCartDialog(cart);
        },
      ),
    );
  }

  void _showCreateCartDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Nuevo carrito',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nombre del carrito',
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final cart = await CartManager.instance.createCart(name);
              if (cart != null && mounted) {
                AppSnackBar.success(context, message: 'Carrito "$name" creado');
              } else if (mounted) {
                AppSnackBar.error(context, message: 'Error al crear el carrito');
              }
            },
            child: const Text(
              'Crear',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCartDialog(ApiCartSummary cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar carrito', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${cart.name}"?'
          '${cart.itemCount > 0 ? ' Tiene ${cart.itemCount} producto${cart.itemCount == 1 ? '' : 's'}.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await CartManager.instance.deleteCart(cart.id);
              if (success && mounted) {
                AppSnackBar.success(context, message: 'Carrito "${cart.name}" eliminado');
              } else if (mounted) {
                AppSnackBar.error(context, message: 'Error al eliminar el carrito');
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Vaciar carrito', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas eliminar todos los productos de este carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              CartManager.instance.clearCart();
            },
            child: const Text(
              'Vaciar',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cartName = CartManager.instance.activeCartName;
    final cartCount = CartManager.instance.allCarts.length;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.secondary, AppColors.secondaryLight],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: GestureDetector(
              onTap: _showCartSelector,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      cartName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cartCount > 1) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.unfold_more_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (_cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: _showClearCartDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: CartManager.instance.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) => _buildCartItemCard(_cartItems[index]),
                      ),
                    ),
                    // Botón fijo "Comparar precios"
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _navigateToComparison,
                            splashColor: Colors.white.withValues(alpha: 0.12),
                            highlightColor: Colors.white.withValues(alpha: 0.06),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.compare_arrows_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'Comparar precios',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty cart
  // ---------------------------------------------------------------------------

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explora productos y compara precios\npara comenzar a ahorrar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_basket_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Explorar productos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cart item card
  // ---------------------------------------------------------------------------

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: item.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ProductImage(
                            url: item.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_) => Icon(
                              Icons.shopping_basket_rounded,
                              size: 26,
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.shopping_basket_rounded,
                          size: 26,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Nombre y supermercado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.supermarketName.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.store_rounded, size: 12, color: AppColors.grey.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            item.supermarketName,
                            style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Eliminar
              GestureDetector(
                onTap: () => CartManager.instance.removeItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close_rounded, color: AppColors.error.withValues(alpha: 0.6), size: 14),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.grey.withValues(alpha: 0.08)),
          ),
          // Precio + controles de cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.price > 0)
                Text(
                  widget.currency == 'USD'
                      ? '\$ ${item.priceUsd.toStringAsFixed(2)}'
                      : 'Bs. ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              else
                Text(
                  'Cantidad: ${item.quantity}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey),
                ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (item.quantity > 1) {
                          CartManager.instance.updateItemQuantity(item.id, item.quantity - 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: item.quantity > 1 ? AppColors.black : AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => CartManager.instance.updateItemQuantity(item.id, item.quantity + 1),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Bottom sheet para seleccionar / gestionar carritos
// =============================================================================

class _CartSelectorSheet extends StatelessWidget {
  final List<ApiCartSummary> carts;
  final String? activeCartId;
  final void Function(String cartId) onSelectCart;
  final VoidCallback onCreateCart;
  final void Function(ApiCartSummary cart) onDeleteCart;

  const _CartSelectorSheet({
    required this.carts,
    required this.activeCartId,
    required this.onSelectCart,
    required this.onCreateCart,
    required this.onDeleteCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis carritos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                GestureDetector(
                  onTap: onCreateCart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Nuevo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: carts.length,
              itemBuilder: (context, index) {
                final cart = carts[index];
                final isActive = cart.id == activeCartId;
                return ListTile(
                  onTap: () => onSelectCart(cart.id),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      size: 20,
                      color: isActive ? AppColors.primary : AppColors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  title: Text(
                    cart.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Text(
                    '${cart.itemCount} producto${cart.itemCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.7)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Activo',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      if (carts.length > 1) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onDeleteCart(cart),
                          child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.grey.withValues(alpha: 0.4)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
