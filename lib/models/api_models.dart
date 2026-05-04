// Modelos que mapean exactamente las respuestas JSON del backend (ca-api).
// Cada clase tiene un factory fromJson que parsea la respuesta real.

// =============================================================================
// Auth
// =============================================================================

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

// =============================================================================
// User
// =============================================================================

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;
  final String currency;
  final String language;
  final bool notificationsEnabled;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    required this.currency,
    required this.language,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String? ?? 'consumer',
      currency: json['preferenceCurrency'] as String? ??
          json['currency'] as String? ??
          'VES',
      language: json['preferenceLanguage'] as String? ??
          json['language'] as String? ??
          'es',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

// =============================================================================
// Brand
// =============================================================================

class ApiBrand {
  final String id;
  final String name;

  ApiBrand({required this.id, required this.name});

  factory ApiBrand.fromJson(Map<String, dynamic> json) {
    return ApiBrand(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

// =============================================================================
// Category
// =============================================================================

class ApiCategory {
  final String id;
  final String name;
  final String? parentId;
  final int productCount;

  ApiCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.productCount = 0,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      productCount: json['productCount'] as int? ?? 0,
    );
  }
}

// =============================================================================
// Price Snapshot (viene en el listado de productos)
// =============================================================================

class PriceSnapshot {
  final double? cheapestPriceUsd;
  final double? cheapestPriceBs;
  final double? cheapestPricePerUnitUsd;
  final double? cheapestPricePerUnitBs;
  final String? cheapestSupermarket;
  final String? cheapestStore;
  final String? cheapestScrapedAt;
  final bool? cheapestAvailable;

  PriceSnapshot({
    this.cheapestPriceUsd,
    this.cheapestPriceBs,
    this.cheapestPricePerUnitUsd,
    this.cheapestPricePerUnitBs,
    this.cheapestSupermarket,
    this.cheapestStore,
    this.cheapestScrapedAt,
    this.cheapestAvailable,
  });

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    return PriceSnapshot(
      cheapestPriceUsd: _toDouble(json['cheapestPriceUsd']),
      cheapestPriceBs: _toDouble(json['cheapestPriceBs']),
      cheapestPricePerUnitUsd: _toDouble(json['cheapestPricePerUnitUsd']),
      cheapestPricePerUnitBs: _toDouble(json['cheapestPricePerUnitBs']),
      cheapestSupermarket: json['cheapestSupermarket'] as String?,
      cheapestStore: json['cheapestStore'] as String?,
      cheapestScrapedAt: json['cheapestScrapedAt'] as String?,
      cheapestAvailable: json['cheapestAvailable'] as bool?,
    );
  }
}

// =============================================================================
// Product Summary (listado de productos)
// =============================================================================

class ApiProductSummary {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String unitType;
  final double baseAmount;
  final String? imageUrl;
  final ApiBrand? brand;
  final ApiCategory category;
  final DateTime? updatedAt;
  final PriceSnapshot? priceSnapshot;

  ApiProductSummary({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.unitType,
    required this.baseAmount,
    this.imageUrl,
    this.brand,
    required this.category,
    this.updatedAt,
    this.priceSnapshot,
  });

  factory ApiProductSummary.fromJson(Map<String, dynamic> json) {
    return ApiProductSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      unitType: json['unitType'] as String? ?? 'unit',
      baseAmount: _toDouble(json['baseAmount']) ?? 1.0,
      imageUrl: json['imageUrl'] as String?,
      brand: json['brand'] != null
          ? ApiBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      category: ApiCategory.fromJson(json['category'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      priceSnapshot: json['priceSnapshot'] != null
          ? PriceSnapshot.fromJson(json['priceSnapshot'] as Map<String, dynamic>)
          : null,
    );
  }
}

// =============================================================================
// Product Detail (detalle con precios por supermercado)
// =============================================================================

class ApiProductDetail {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String unitType;
  final double baseAmount;
  final String? imageUrl;
  final ApiBrand? brand;
  final ApiCategory category;
  final DateTime? updatedAt;
  final Map<String, dynamic>? dwh;
  final Map<String, List<Map<String, dynamic>>> pricesBySupermarket;
  final List<Map<String, dynamic>> offers;
  final Map<String, dynamic>? cheapest;

  ApiProductDetail({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.unitType,
    required this.baseAmount,
    this.imageUrl,
    this.brand,
    required this.category,
    this.updatedAt,
    this.dwh,
    required this.pricesBySupermarket,
    required this.offers,
    this.cheapest,
  });

  factory ApiProductDetail.fromJson(Map<String, dynamic> json) {
    // Parsear pricesBySupermarket: Map<String, List<dynamic>>
    final rawPrices = json['pricesBySupermarket'] as Map<String, dynamic>? ?? {};
    final pricesBySupermarket = <String, List<Map<String, dynamic>>>{};
    rawPrices.forEach((key, value) {
      if (value is List) {
        pricesBySupermarket[key] = value
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    });

    return ApiProductDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      unitType: json['unitType'] as String? ?? 'unit',
      baseAmount: _toDouble(json['baseAmount']) ?? 1.0,
      imageUrl: json['imageUrl'] as String?,
      brand: json['brand'] != null
          ? ApiBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      category: ApiCategory.fromJson(json['category'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      dwh: json['dwh'] as Map<String, dynamic>?,
      pricesBySupermarket: pricesBySupermarket,
      offers: (json['offers'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      cheapest: json['cheapest'] as Map<String, dynamic>?,
    );
  }
}

// =============================================================================
// Paginated Response (para listados)
// =============================================================================

class PaginatedResponse<T> {
  final int page;
  final int limit;
  final int total;
  final List<T> items;

  PaginatedResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.items,
  });

  bool get hasNextPage => page * limit < total;
  int get totalPages => (total / limit).ceil();
}

// =============================================================================
// Supermarket
// =============================================================================

class ApiSupermarket {
  final String id;
  final String name;
  final String? slug;
  final String? logoUrl;
  final String? website;
  final bool isActive;

  ApiSupermarket({
    required this.id,
    required this.name,
    this.slug,
    this.logoUrl,
    this.website,
    required this.isActive,
  });

  factory ApiSupermarket.fromJson(Map<String, dynamic> json) {
    return ApiSupermarket(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// =============================================================================
// DWH Supermarket (para filtros de productos)
// =============================================================================

class DwhSupermarket {
  final int id;
  final String name;
  final String? slug;
  final String? logoUrl;

  DwhSupermarket({
    required this.id,
    required this.name,
    this.slug,
    this.logoUrl,
  });

  factory DwhSupermarket.fromJson(Map<String, dynamic> json) {
    return DwhSupermarket(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}

// =============================================================================
// Cart
// =============================================================================

class ApiCartSummary {
  final String id;
  final String name;
  final DateTime updatedAt;
  final int itemCount;

  ApiCartSummary({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.itemCount,
  });

  factory ApiCartSummary.fromJson(Map<String, dynamic> json) {
    return ApiCartSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }
}

class ApiCartItem {
  final String id;
  final double quantity;
  final String? preferredSupermarketId;
  final ApiCartItemSupermarket? preferredSupermarket;
  final ApiCartItemProduct product;

  ApiCartItem({
    required this.id,
    required this.quantity,
    this.preferredSupermarketId,
    this.preferredSupermarket,
    required this.product,
  });

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    return ApiCartItem(
      id: json['id'] as String,
      quantity: _toDouble(json['quantity']) ?? 1.0,
      preferredSupermarketId: json['preferredSupermarketId'] as String?,
      preferredSupermarket: json['preferredSupermarket'] != null
          ? ApiCartItemSupermarket.fromJson(
              json['preferredSupermarket'] as Map<String, dynamic>)
          : null,
      product: ApiCartItemProduct.fromJson(
          json['product'] as Map<String, dynamic>),
    );
  }
}

class ApiCartItemProduct {
  final String id;
  final String name;
  final String? slug;
  final String unitType;
  final double baseAmount;
  final String? imageUrl;
  final ApiBrand? brand;
  final ApiCategory category;

  ApiCartItemProduct({
    required this.id,
    required this.name,
    this.slug,
    required this.unitType,
    required this.baseAmount,
    this.imageUrl,
    this.brand,
    required this.category,
  });

  factory ApiCartItemProduct.fromJson(Map<String, dynamic> json) {
    return ApiCartItemProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      unitType: json['unitType'] as String? ?? 'unit',
      baseAmount: _toDouble(json['baseAmount']) ?? 1.0,
      imageUrl: json['imageUrl'] as String?,
      brand: json['brand'] != null
          ? ApiBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      category: ApiCategory.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}

class ApiCartItemSupermarket {
  final String id;
  final String name;

  ApiCartItemSupermarket({required this.id, required this.name});

  factory ApiCartItemSupermarket.fromJson(Map<String, dynamic> json) {
    return ApiCartItemSupermarket(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ApiCartDetail {
  final String id;
  final String name;
  final DateTime updatedAt;
  final List<ApiCartItem> items;

  ApiCartDetail({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.items,
  });

  factory ApiCartDetail.fromJson(Map<String, dynamic> json) {
    return ApiCartDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ApiCartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// =============================================================================
// Favorites
// =============================================================================

class ApiFavoriteItem {
  final String productId;
  final DateTime favoritedAt;
  final ApiCartItemProduct? product;

  ApiFavoriteItem({
    required this.productId,
    required this.favoritedAt,
    this.product,
  });

  factory ApiFavoriteItem.fromJson(Map<String, dynamic> json) {
    return ApiFavoriteItem(
      productId: json['productId'] as String,
      favoritedAt: DateTime.parse(json['favoritedAt'] as String),
      product: json['product'] != null
          ? ApiCartItemProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}

// =============================================================================
// Offers
// =============================================================================

class ApiOffer {
  final String id;
  final String title;
  final String? description;
  final String? badge;
  final String? imageUrl;
  final String? linkUrl;
  final String startsAt;
  final String endsAt;
  final bool isActive;
  final bool isBanner;
  final int sortOrder;
  final String targetType;
  final String? productId;
  final String? categoryId;
  final String? supermarketId;
  final String? storeId;

  ApiOffer({
    required this.id,
    required this.title,
    this.description,
    this.badge,
    this.imageUrl,
    this.linkUrl,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    required this.isBanner,
    required this.sortOrder,
    required this.targetType,
    this.productId,
    this.categoryId,
    this.supermarketId,
    this.storeId,
  });

  factory ApiOffer.fromJson(Map<String, dynamic> json) {
    return ApiOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      badge: json['badge'] as String?,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      startsAt: json['startsAt'] as String,
      endsAt: json['endsAt'] as String,
      isActive: json['isActive'] as bool? ?? true,
      isBanner: json['isBanner'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      targetType: json['targetType'] as String? ?? 'general',
      productId: json['productId'] as String?,
      categoryId: json['categoryId'] as String?,
      supermarketId: json['supermarketId'] as String?,
      storeId: json['storeId'] as String?,
    );
  }
}

// =============================================================================
// Deals (ofertas detectadas desde DWH)
// =============================================================================

class ApiDeal {
  final String? productId;
  final String productName;
  final String? productSlug;
  final String unitType;
  final double baseAmount;
  final String storeName;
  final String supermarketName;
  final String supermarketSlug;
  final double priceUsd;
  final double priceBs;
  final double? pricePerUnitUsd;
  final double? pricePerUnitBs;
  final double? originalPriceUsd;
  final double? originalPriceBs;
  final double discountPct;
  final String? imageUrl;
  final String? scrapedAt;

  ApiDeal({
    this.productId,
    required this.productName,
    this.productSlug,
    required this.unitType,
    required this.baseAmount,
    required this.storeName,
    required this.supermarketName,
    required this.supermarketSlug,
    required this.priceUsd,
    required this.priceBs,
    this.pricePerUnitUsd,
    this.pricePerUnitBs,
    this.originalPriceUsd,
    this.originalPriceBs,
    required this.discountPct,
    this.imageUrl,
    this.scrapedAt,
  });

  factory ApiDeal.fromJson(Map<String, dynamic> json) {
    return ApiDeal(
      productId: json['productId'] as String?,
      productName: json['productName'] as String? ?? '',
      productSlug: json['productSlug'] as String?,
      unitType: json['unitType'] as String? ?? 'unit',
      baseAmount: _toDouble(json['baseAmount']) ?? 1.0,
      storeName: json['storeName'] as String? ?? '',
      supermarketName: json['supermarketName'] as String? ?? '',
      supermarketSlug: json['supermarketSlug'] as String? ?? '',
      priceUsd: _toDouble(json['priceUsd']) ?? 0.0,
      priceBs: _toDouble(json['priceBs']) ?? 0.0,
      pricePerUnitUsd: _toDouble(json['pricePerUnitUsd']),
      pricePerUnitBs: _toDouble(json['pricePerUnitBs']),
      originalPriceUsd: _toDouble(json['originalPriceUsd']),
      originalPriceBs: _toDouble(json['originalPriceBs']),
      discountPct: _toDouble(json['discountPct']) ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      scrapedAt: json['scrapedAt'] as String?,
    );
  }
}

// =============================================================================
// Price Insights (historial de precios)
// =============================================================================

class ApiPriceInsights {
  final String productId;
  final String name;
  final int days;
  final Map<String, dynamic> comparison;
  final List<Map<String, dynamic>> historyDaily;

  ApiPriceInsights({
    required this.productId,
    required this.name,
    required this.days,
    required this.comparison,
    required this.historyDaily,
  });

  factory ApiPriceInsights.fromJson(Map<String, dynamic> json) {
    return ApiPriceInsights(
      productId: json['productId'] as String,
      name: json['name'] as String,
      days: json['days'] as int? ?? 30,
      comparison: json['comparison'] as Map<String, dynamic>? ?? {},
      historyDaily: (json['historyDaily'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
