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
            TextButton.icon(
              onPressed: () {
                // TODO: Limpiar carrito
              },
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Vaciar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Comparador de supermercados
                if (_availableSupermarkets.length > 1)
                  _buildSupermarketComparison(),

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

                // Resumen del carrito
                _buildCartSummary(),
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
            decoration: BoxDecoration(
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

  Widget _buildSupermarketComparison() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Comparación de Precios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._availableSupermarkets.map((supermarketId) {
            final total = _getTotalForSupermarket(supermarketId);
            final name = _getSupermarketName(supermarketId);
            final isCheapest = supermarketId == _cheapestSupermarket;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCheapest
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCheapest
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: isCheapest ? AppColors.primary : AppColors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCheapest
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (isCheapest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Más barato',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    'Bs. ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
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
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Imagen del producto
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Center(
              child: item.product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.shopping_basket,
                            size: 40,
                            color: AppColors.primary.withOpacity(0.5),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.shopping_basket,
                      size: 40,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
            ),
          ),

          // Información del producto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: AppColors.grey.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.supermarketName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio unitario
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bs. ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '/${item.product.unit}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),

                      // Controles de cantidad
                      Row(
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botón eliminar
          GestureDetector(
            onTap: () => widget.onRemoveItem(item.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    final itemCount = widget.cartItems.fold(0, (sum, item) => sum + item.quantity);
    final cheapest = _cheapestSupermarket;
    final savings = cheapest != null
        ? _cartTotal - _getTotalForSupermarket(cheapest)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de productos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '$itemCount ${itemCount == 1 ? "item" : "items"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                if (savings > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Puedes ahorrar',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'Bs. ${savings.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Bs. ${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
