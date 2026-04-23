import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/cart_item.dart';
import '../models/api_models.dart';
import '../services/api.dart';
import '../services/cart_manager.dart';
import '../widgets/app_snack_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Comparación de precios
  String _compareMode = 'single'; // 'single' | 'mixed'
  Map<String, dynamic>? _comparisonData;
  bool _isLoadingComparison = false;

  @override
  void initState() {
    super.initState();
    CartManager.instance.addListener(_onCartChanged);
    _loadComparison();
  }

  @override
  void dispose() {
    CartManager.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
      _loadComparison();
    }
  }

  List<CartItem> get _cartItems => CartManager.instance.items;

  Future<void> _loadComparison() async {
    final cartId = CartManager.instance.activeCartId;
    if (cartId == null || _cartItems.isEmpty) {
      setState(() => _comparisonData = null);
      return;
    }

    setState(() => _isLoadingComparison = true);

    try {
      final data = await Api.instance.carts.compare(
        cartId: cartId,
        mode: _compareMode,
      );
      if (mounted) {
        setState(() {
          _comparisonData = data;
          _isLoadingComparison = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _comparisonData = null;
          _isLoadingComparison = false;
        });
      }
    }
  }

  void _switchCompareMode(String mode) {
    if (_compareMode == mode) return;
    setState(() => _compareMode = mode);
    _loadComparison();
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
            hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
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
                      color: Colors.white.withOpacity(0.2),
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
                      color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.2),
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItemCard(_cartItems[index]);
                        },
                      ),
                    ),
                    _buildComparisonSection(),
                  ],
                ),
    );
  }

  // ---------------------------------------------------------------------------
  // Comparación de precios (bottom section)
  // ---------------------------------------------------------------------------

  Widget _buildComparisonSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.grey.withOpacity(0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle de modo
            _buildModeToggle(),

            // Resultados de comparación
            if (_isLoadingComparison)
              const Padding(
                padding: EdgeInsets.all(24),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_comparisonData != null)
              _compareMode == 'single'
                  ? _buildSingleResults()
                  : _buildMixedResults()
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se pudo cargar la comparación',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildModeTab(
              label: 'Un solo super',
              icon: Icons.store_rounded,
              mode: 'single',
            ),
            _buildModeTab(
              label: 'Mejor precio mixto',
              icon: Icons.swap_horiz_rounded,
              mode: 'mixed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required String mode,
  }) {
    final isActive = _compareMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchCompareMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? AppColors.primary : AppColors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Modo Single: ¿En cuál supermercado sale más barato TODO?
  // ---------------------------------------------------------------------------

  Widget _buildSingleResults() {
    final data = _comparisonData!;
    if (data.containsKey('message')) {
      return _buildComparisonMessage(data['message'] as String);
    }

    final supermarkets = data['supermarkets'] as List<dynamic>? ?? [];
    final cheapest = data['cheapest'] as Map<String, dynamic>?;

    if (supermarkets.isEmpty) {
      return _buildComparisonMessage('No hay precios disponibles');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de supermercados
          ...supermarkets.take(5).map((s) {
            final supermarket = s as Map<String, dynamic>;
            final name = supermarket['name'] as String? ?? '';
            final totalUsd = (supermarket['totalUsd'] as num?)?.toDouble() ?? 0;
            final allAvailable = supermarket['allProductsAvailable'] as bool? ?? false;
            final isCheapest = cheapest != null && cheapest['name'] == name;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isCheapest
                    ? AppColors.primaryLight.withOpacity(0.1)
                    : AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCheapest
                      ? AppColors.primary.withOpacity(0.25)
                      : AppColors.grey.withOpacity(0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store_rounded,
                    color: isCheapest
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCheapest ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        if (!allAvailable)
                          Text(
                            'No todos los productos disponibles',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCheapest)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Más barato',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  Text(
                    '\$ ${totalUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isCheapest ? AppColors.primary : AppColors.black,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Ahorro potencial
          if (supermarkets.length > 1) _buildSavingsBadge(supermarkets),
        ],
      ),
    );
  }

  Widget _buildSavingsBadge(List<dynamic> supermarkets) {
    final cheapestTotal =
        (supermarkets.first as Map<String, dynamic>)['totalUsd'] as num? ?? 0;
    final mostExpensiveTotal =
        (supermarkets.last as Map<String, dynamic>)['totalUsd'] as num? ?? 0;
    final savings = (mostExpensiveTotal.toDouble() - cheapestTotal.toDouble());

    if (savings <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.savings_outlined,
              size: 16,
              color: AppColors.primary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ahorras hasta \$ ${savings.toStringAsFixed(2)} eligiendo el supermercado más barato',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Modo Mixed: Mejor precio comprando en varios supermercados
  // ---------------------------------------------------------------------------

  Widget _buildMixedResults() {
    final data = _comparisonData!;
    if (data.containsKey('message')) {
      return _buildComparisonMessage(data['message'] as String);
    }

    final grandTotal = (data['grandTotalUsd'] as num?)?.toDouble() ?? 0;
    final bySupermarket = data['bySupermarket'] as List<dynamic>? ?? [];

    if (bySupermarket.isEmpty) {
      return _buildComparisonMessage('No hay precios disponibles');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total optimizado
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primaryLight.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total optimizado',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$ ${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Desglose por supermercado
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 14,
                color: AppColors.grey.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Comprar en ${bySupermarket.length} supermercado${bySupermarket.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...bySupermarket.map((entry) {
            final s = entry as Map<String, dynamic>;
            final name = s['supermarketName'] as String? ?? '';
            final subtotal = (s['subtotalUsd'] as num?)?.toDouble() ?? 0;
            final purchases = s['purchases'] as List<dynamic>? ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.grey.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store_rounded,
                    color: AppColors.grey.withOpacity(0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '${purchases.length} producto${purchases.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$ ${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Ahorro vs comprar en un solo super
          _buildMixedSavings(),
        ],
      ),
    );
  }

  /// Calcula el ahorro del modo mixto vs el supermercado más barato en single.
  Widget _buildMixedSavings() {
    // Necesitamos comparar con el modo single para mostrar el ahorro.
    // Si no tenemos esos datos, no mostramos nada.
    final mixedTotal =
        (_comparisonData?['grandTotalUsd'] as num?)?.toDouble() ?? 0;
    if (mixedTotal <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.accent.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Precio optimizado comprando cada producto donde sea más barato',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.grey.withOpacity(0.6),
        ),
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: AppColors.primary.withOpacity(0.4),
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
                color: AppColors.grey.withOpacity(0.7),
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
                      color: AppColors.primary.withOpacity(0.25),
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
        border: Border.all(color: AppColors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: AppColors.lightGrey.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: item.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.shopping_basket_rounded,
                              size: 26,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.shopping_basket_rounded,
                          size: 26,
                          color: AppColors.primary.withOpacity(0.3),
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
                          Icon(Icons.store_rounded, size: 12, color: AppColors.grey.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            item.supermarketName,
                            style: TextStyle(fontSize: 11, color: AppColors.grey.withOpacity(0.6)),
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
                    color: AppColors.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close_rounded, color: AppColors.error.withOpacity(0.6), size: 14),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.grey.withOpacity(0.08)),
          ),
          // Precio + controles de cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.price > 0)
                Text(
                  'Bs. ${item.price.toStringAsFixed(2)}',
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
                  color: AppColors.lightGrey.withOpacity(0.5),
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
                          border: Border.all(color: AppColors.grey.withOpacity(0.08)),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: item.quantity > 1 ? AppColors.black : AppColors.grey.withOpacity(0.3),
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
                              color: AppColors.primary.withOpacity(0.25),
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
              color: AppColors.grey.withOpacity(0.3),
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
                      color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      size: 20,
                      color: isActive ? AppColors.primary : AppColors.grey.withOpacity(0.5),
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
                    style: TextStyle(fontSize: 12, color: AppColors.grey.withOpacity(0.7)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
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
                          child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.grey.withOpacity(0.4)),
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
