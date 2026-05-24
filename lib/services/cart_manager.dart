import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/api_models.dart';
import 'api.dart';

/// Gestor centralizado del carrito de compras.
///
/// El carrito solo persiste **productId + quantity** en el backend.
/// Los precios se consultan en tiempo real al cargar el carrito,
/// garantizando que siempre se muestren los precios más recientes
/// (incluso si el scraper actualizó precios durante la noche).
///
/// Soporta múltiples carritos por usuario.
class CartManager extends ChangeNotifier {
  static final CartManager instance = CartManager._();
  CartManager._();

  /// Lista de todos los carritos del usuario.
  List<ApiCartSummary> _allCarts = [];

  /// ID del carrito activo.
  String? _activeCartId;

  /// Items del carrito activo (enriquecidos con precios al momento de cargar).
  List<CartItem> _items = [];

  bool _initialized = false;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<ApiCartSummary> get allCarts => List.unmodifiable(_allCarts);
  String? get activeCartId => _activeCartId;

  String get activeCartName {
    if (_activeCartId == null) return 'Mi Carrito';
    final cart = _allCarts.cast<ApiCartSummary?>().firstWhere(
          (c) => c!.id == _activeCartId,
          orElse: () => null,
        );
    return cart?.name ?? 'Mi Carrito';
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  // ---------------------------------------------------------------------------
  // Inicialización
  // ---------------------------------------------------------------------------

  /// Inicializar — llamar después del login.
  /// Carga la lista de carritos y selecciona el primero (o crea uno por defecto).
  Future<void> init() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      _allCarts = await Api.instance.carts.list();

      if (_allCarts.isEmpty) {
        final cart = await Api.instance.carts.create('Mi Carrito');
        _allCarts = [cart];
      }

      _activeCartId = _allCarts.first.id;
      await _loadActiveCartItems();
    } catch (e) {
      debugPrint('[CartManager.init] $e');
    }

    _initialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Gestión de múltiples carritos
  // ---------------------------------------------------------------------------

  /// Cambiar al carrito indicado y cargar sus items.
  Future<void> switchCart(String cartId) async {
    if (_activeCartId == cartId) return;
    _activeCartId = cartId;
    _items = [];
    _isLoading = true;
    notifyListeners();

    await _loadActiveCartItems();

    _isLoading = false;
    notifyListeners();
  }

  /// Crear un nuevo carrito y activarlo.
  Future<ApiCartSummary?> createCart(String name) async {
    try {
      final cart = await Api.instance.carts.create(name);
      _allCarts = [..._allCarts, cart];
      _activeCartId = cart.id;
      _items = [];
      notifyListeners();
      return cart;
    } catch (e) {
      debugPrint('[CartManager.createCart] $e');
      return null;
    }
  }

  /// Eliminar un carrito. Si es el activo, cambia al primero disponible.
  Future<bool> deleteCart(String cartId) async {
    try {
      await Api.instance.carts.delete(cartId);
      _allCarts = _allCarts.where((c) => c.id != cartId).toList();

      if (_activeCartId == cartId) {
        if (_allCarts.isNotEmpty) {
          _activeCartId = _allCarts.first.id;
          await _loadActiveCartItems();
        } else {
          final cart = await Api.instance.carts.create('Mi Carrito');
          _allCarts = [cart];
          _activeCartId = cart.id;
          _items = [];
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[CartManager.deleteCart] $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Operaciones sobre items del carrito activo
  // ---------------------------------------------------------------------------

  /// Agregar producto al carrito activo.
  /// Solo envía productId + quantity al backend.
  /// Los precios se recargan desde el backend después.
  Future<void> addItem(Product product) async {
    // Optimista: agregar localmente de inmediato para UX fluida
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      final defaultSupermarketId = product.prices.isNotEmpty
          ? product.prices.first.supermarketId
          : '';
      _items.add(CartItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: 1,
        selectedSupermarketId: defaultSupermarketId,
        addedAt: DateTime.now(),
      ));
    }
    notifyListeners();

    // Sincronizar con backend (solo productId + quantity)
    if (_activeCartId != null) {
      try {
        await Api.instance.carts.addItem(
          cartId: _activeCartId!,
          productId: product.id,
          quantity: 1,
        );
        // Recargar items con IDs reales del backend
        await _loadActiveCartItems();
        _refreshCartSummaries();
        notifyListeners();
      } catch (e) {
        debugPrint('[CartManager.addItem] $e');
      }
    }
  }

  /// Eliminar item del carrito activo.
  Future<void> removeItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();

    if (_activeCartId != null) {
      try {
        await Api.instance.carts.removeItem(
          cartId: _activeCartId!,
          itemId: itemId,
        );
        _refreshCartSummaries();
      } catch (e) {
        debugPrint('[CartManager.removeItem] $e');
      }
    }
  }

  /// Actualizar cantidad de un item.
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    _items[index] = _items[index].copyWith(quantity: newQuantity);
    notifyListeners();

    if (_activeCartId != null) {
      try {
        await Api.instance.carts.updateItem(
          cartId: _activeCartId!,
          itemId: itemId,
          quantity: newQuantity.toDouble(),
        );
      } catch (e) {
        debugPrint('[CartManager.updateItemQuantity] $e');
      }
    }
  }

  /// Limpiar todos los items del carrito activo.
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    if (_activeCartId != null) {
      try {
        await Api.instance.carts.clearItems(_activeCartId!);
        _refreshCartSummaries();
      } catch (e) {
        debugPrint('[CartManager.clearCart] $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Resetear (al cerrar sesión)
  // ---------------------------------------------------------------------------

  void reset() {
    _activeCartId = null;
    _allCarts = [];
    _items = [];
    _initialized = false;
    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  /// Cargar items del carrito activo desde el backend,
  /// luego enriquecer cada producto con sus precios actuales en paralelo.
  Future<void> _loadActiveCartItems() async {
    if (_activeCartId == null) return;
    try {
      final detail = await Api.instance.carts.getDetail(_activeCartId!);
      if (detail.items.isEmpty) {
        _items = [];
        return;
      }

      // Pedir detalle de todos los productos en paralelo para obtener precios actuales
      final productDetailFutures = detail.items.map(
        (apiItem) => Api.instance.products.getDetail(apiItem.product.id),
      );
      final productDetails = await Future.wait(
        productDetailFutures,
        eagerError: false,
      );

      // Construir map de productId → Product con precios frescos
      final productMap = <String, Product>{};
      for (final apiDetail in productDetails) {
        productMap[apiDetail.id] = _productFromDetail(apiDetail);
      }

      // Armar CartItems con datos completos
      _items = detail.items.map((apiItem) {
        final product = productMap[apiItem.product.id] ??
            _minimalProduct(apiItem.product);

        return CartItem(
          id: apiItem.id,
          product: product,
          quantity: apiItem.quantity.toInt(),
          selectedSupermarketId: apiItem.preferredSupermarketId ??
              (product.prices.isNotEmpty
                  ? product.prices.first.supermarketId
                  : ''),
          addedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[CartManager._loadActiveCartItems] $e');
    }
  }

  /// Construir un Product completo con precios desde ApiProductDetail.
  /// Usa la misma lógica que ProductDetailScreen._loadFullDetail().
  Product _productFromDetail(ApiProductDetail detail) {
    final prices = <PriceInfo>[];
    for (final entry in detail.pricesBySupermarket.entries) {
      final supermarketName = entry.key;
      for (final offer in entry.value) {
        prices.add(PriceInfo(
          supermarketId: offer['store_dw_key']?.toString() ?? '',
          supermarketName: supermarketName,
          supermarketLogo: '',
          price: (offer['price_bs'] as num?)?.toDouble() ?? 0.0,
          priceUsd: (offer['price_usd'] as num?)?.toDouble(),
          lastUpdated: offer['scraped_at'] != null
              ? DateTime.tryParse(offer['scraped_at'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
        ));
      }
    }

    return Product(
      id: detail.id,
      name: detail.name,
      slug: detail.slug ?? '',
      description: detail.description ?? '',
      imageUrl: detail.imageUrl ?? '',
      category: detail.category.name,
      categoryId: detail.category.id,
      prices: prices,
      averagePrice: prices.isNotEmpty
          ? prices.map((p) => p.price).reduce((a, b) => a + b) / prices.length
          : 0.0,
      unit: detail.unitType,
    );
  }

  /// Refrescar los summaries de los carritos (para actualizar itemCount).
  void _refreshCartSummaries() async {
    try {
      _allCarts = await Api.instance.carts.list();
      notifyListeners();
    } catch (e) {
      debugPrint('[CartManager._refreshCartSummaries] $e');
    }
  }

  /// Convertir ApiCartItemProduct a Product (sin precios — fallback).
  Product _minimalProduct(ApiCartItemProduct apiProduct) {
    return Product(
      id: apiProduct.id,
      name: apiProduct.name,
      slug: apiProduct.slug ?? '',
      description: '',
      imageUrl: apiProduct.imageUrl ?? '',
      category: apiProduct.category.name,
      categoryId: apiProduct.category.id,
      prices: [],
      averagePrice: 0,
      unit: apiProduct.unitType,
    );
  }
}
