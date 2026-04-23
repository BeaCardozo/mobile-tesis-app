class Product {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String category;
  final int categoryId;
  final List<PriceInfo> prices;
  final double averagePrice;
  final String unit;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.slug = '',
    required this.description,
    required this.imageUrl,
    required this.category,
    this.categoryId = 0,
    required this.prices,
    required this.averagePrice,
    required this.unit,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] is Map
          ? (json['category']['name'] as String? ?? '')
          : (json['category'] as String? ?? ''),
      categoryId: json['categoryId'] as int? ?? 0,
      prices: (json['prices'] as List<dynamic>?)
              ?.map((price) => PriceInfo.fromJson(price as Map<String, dynamic>))
              .toList() ??
          [],
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      unit: json['baseUnit'] as String? ?? json['unit'] as String? ?? 'unidad',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'categoryId': categoryId,
      'prices': prices.map((price) => price.toJson()).toList(),
      'averagePrice': averagePrice,
      'unit': unit,
      'isFavorite': isFavorite,
    };
  }

  double get lowestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  double get highestPrice {
    if (prices.isEmpty) return 0.0;
    return prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  Product copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    String? category,
    int? categoryId,
    List<PriceInfo>? prices,
    double? averagePrice,
    String? unit,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
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

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      supermarketId: json['supermarketId'] as String,
      supermarketName: json['supermarketName'] as String,
      supermarketLogo: json['supermarketLogo'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

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
