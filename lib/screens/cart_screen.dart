import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(String) onRemoveItem;
  final Function(String, int) onUpdateQuantity;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // Obtener lista de supermercados únicos
  List<String> get _availableSupermarkets {
    final supermarkets = <String>{};
    for (var item in widget.cartItems) {
      for (var price in item.product.prices) {
        supermarkets.add(price.supermarketId);
      }
    }
    return supermarkets.toList();
  }

  // Calcular total del carrito
  double get _cartTotal {
    return widget.cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Calcular total por supermercado específico
  double _getTotalForSupermarket(String supermarketId) {
    double total = 0;
    for (var item in widget.cartItems) {
      final priceInfo = item.product.prices.firstWhere(
        (p) => p.supermarketId == supermarketId,
        orElse: () => item.product.prices.first,
      );
      total += priceInfo.price * item.quantity;
    }
    return total;
  }

  // Obtener nombre del supermercado
  String _getSupermarketName(String supermarketId) {
    for (var item in widget.cartItems) {
      final priceInfo = item.product.prices.firstWhere(
        (p) => p.supermarketId == supermarketId,
        orElse: () => item.product.prices.first,
      );
      if (priceInfo.supermarketId == supermarketId) {
        return priceInfo.supermarketName;
      }
    }
    return 'Supermercado';
  }

  // Encontrar el supermercado más barato
  String? get _cheapestSupermarket {
    if (_availableSupermarkets.isEmpty) return null;

    String? cheapest;
    double minTotal = double.infinity;

    for (var supermarketId in _availableSupermarkets) {
      final total = _getTotalForSupermarket(supermarketId);
      if (total < minTotal) {
        minTotal = total;
        cheapest = supermarketId;
      }
    }

    return cheapest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (widget.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  // TODO: Limpiar carrito
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: 'Vaciar carrito',
              ),
            ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de productos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItemCard(widget.cartItems[index]);
                    },
                  ),
                ),

                // Comparador + resumen fijos abajo
                _buildBottomSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.grey.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar a comprar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_basket),
            label: const Text('Ir a comprar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final itemCount = widget.cartItems.fold(0, (sum, item) => sum + item.quantity);
    final cheapest = _cheapestSupermarket;
    final savings = cheapest != null
        ? _cartTotal - _getTotalForSupermarket(cheapest)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Comparación de supermercados
            if (_availableSupermarkets.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_arrows_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Comparar supermercados',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._availableSupermarkets.map((supermarketId) {
                      final total = _getTotalForSupermarket(supermarketId);
                      final name = _getSupermarketName(supermarketId);
                      final isCheapest = supermarketId == _cheapestSupermarket;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCheapest
                              ? AppColors.primaryLight.withOpacity(0.12)
                              : AppColors.lightGrey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCheapest
                                ? AppColors.primary.withOpacity(0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              color: isCheapest
                                  ? AppColors.primary
                                  : AppColors.grey.withOpacity(0.6),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCheapest
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            if (isCheapest)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.primary.withOpacity(0.8),
                                ),
                              ),
                            Text(
                              'Bs. ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isCheapest
                                    ? AppColors.primary
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Divider(
                        height: 1,
                        color: AppColors.grey.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),

            // Resumen del total
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($itemCount ${itemCount == 1 ? "producto" : "productos"})',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bs. ${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (savings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 14,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ahorra Bs. ${savings.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
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

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila superior: imagen, nombre, supermercado y botón eliminar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: item.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.shopping_basket_rounded,
                                size: 28,
                                color: AppColors.primary.withOpacity(0.4),
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.shopping_basket_rounded,
                          size: 28,
                          color: AppColors.primary.withOpacity(0.4),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.store_rounded,
                          size: 13,
                          color: AppColors.grey.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.supermarketName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              GestureDetector(
                onTap: () => widget.onRemoveItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.error.withOpacity(0.7),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          // Separador
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: AppColors.grey.withOpacity(0.12),
            ),
          ),

          // Fila inferior: precio y controles de cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Precio
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bs. ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '/${item.product.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              // Controles de cantidad
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (item.quantity > 1) {
                          widget.onUpdateQuantity(
                            item.id,
                            item.quantity - 1,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 18,
                          color: item.quantity > 1
                              ? AppColors.black
                              : AppColors.grey.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onUpdateQuantity(
                          item.id,
                          item.quantity + 1,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
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
