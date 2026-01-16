import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String selectedSupermarketId; // Supermercado seleccionado para este producto
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedSupermarketId,
    required this.addedAt,
  });

  // Precio del producto en el supermercado seleccionado
  double get price {
    final priceInfo = product.prices.firstWhere(
      (p) => p.supermarketId == selectedSupermarketId,
      orElse: () => product.prices.first,
    );
    return priceInfo.price;
  }

  // Subtotal de este item (precio × cantidad)
  double get subtotal => price * quantity;

  // Nombre del supermercado seleccionado
  String get supermarketName {
    final priceInfo = product.prices.firstWhere(
      (p) => p.supermarketId == selectedSupermarketId,
      orElse: () => product.prices.first,
    );
    return priceInfo.supermarketName;
  }

  // Constructor para facilitar la conversión desde JSON cuando se implemente el backend
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedSupermarketId: json['selectedSupermarketId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  // Método para convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSupermarketId': selectedSupermarketId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Método para copiar el item con algunos campos modificados
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSupermarketId,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSupermarketId:
          selectedSupermarketId ?? this.selectedSupermarketId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
