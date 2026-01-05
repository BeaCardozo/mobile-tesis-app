class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final List<PriceInfo> prices;
  final double averagePrice;
  final String unit;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.prices,
    required this.averagePrice,
    required this.unit,
    this.isFavorite = false,
  });

  // Constructor para facilitar la conversión desde JSON cuando se implemente el backend
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String,
      prices: (json['prices'] as List<dynamic>?)
              ?.map((price) => PriceInfo.fromJson(price as Map<String, dynamic>))
              .toList() ??
          [],
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'unidad',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  // Método para convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'prices': prices.map((price) => price.toJson()).toList(),
      'averagePrice': averagePrice,
      'unit': unit,
      'isFavorite': isFavorite,
    };
  }

  // Método para obtener el precio más bajo
  double get lowestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  // Método para obtener el precio más alto
  double get highestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  // Método para copiar el producto con algunos campos modificados
  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    List<PriceInfo>? prices,
    double? averagePrice,
    String? unit,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      prices: prices ?? this.prices,
      averagePrice: averagePrice ?? this.averagePrice,
      unit: unit ?? this.unit,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class PriceInfo {
  final String supermarketId;
  final String supermarketName;
  final String supermarketLogo;
  final double price;
  final DateTime lastUpdated;

  PriceInfo({
    required this.supermarketId,
    required this.supermarketName,
    required this.supermarketLogo,
    required this.price,
    required this.lastUpdated,
  });

  // Constructor para facilitar la conversión desde JSON
  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      supermarketId: json['supermarketId'] as String,
      supermarketName: json['supermarketName'] as String,
      supermarketLogo: json['supermarketLogo'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'supermarketId': supermarketId,
      'supermarketName': supermarketName,
      'supermarketLogo': supermarketLogo,
      'price': price,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
