import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/api_models.dart';
import '../services/api.dart';
import '../services/cart_manager.dart';
import '../widgets/product_card.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const ProductsScreen({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filtros
  String? _selectedCategoryId;
  String? _selectedSupermarketName;
  double _minPrice = 0;
  double _maxPrice = 50;
  String _sortBy = 'Relevancia';

  List<Category> _categories = [];
  List<ApiSupermarket> _supermarkets = [];
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    CartManager.instance.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  /// Mapea la etiqueta de orden de la UI al valor que espera el backend.
  String? _mapSortBy(String sortLabel) {
    switch (sortLabel) {
      case 'Precio: Menor a Mayor':
        return 'priceAsc';
      case 'Precio: Mayor a Menor':
        return 'priceDesc';
      case 'Nombre A-Z':
        return 'nameAsc';
      default:
        return null; // Relevancia → orden por defecto del backend
    }
  }

  Future<void> _loadData({String? search}) async {
    setState(() => _isLoading = true);

    // Cargar supermercados por separado para que no bloquee productos
    if (_supermarkets.isEmpty) {
      Api.instance.supermarkets.listAll().then((list) {
        if (mounted && list.isNotEmpty) setState(() => _supermarkets = list);
      }).catchError((_) {});
    }

    try {
      final bool priceFilterActive = _minPrice > 0 || _maxPrice < 50;

      final results = await Future.wait([
        Api.instance.categories.listAll(),
        Api.instance.products.list(
          search: search,
          categoryId: _selectedCategoryId,
          supermarketName: _selectedSupermarketName,
          minPrice: priceFilterActive ? _minPrice : null,
          maxPrice: priceFilterActive ? _maxPrice : null,
          sortBy: _mapSortBy(_sortBy),
          limit: 50,
        ),
      ]);

      final apiCategories = results[0] as List;
      final paginatedProducts = results[1];

      if (mounted) {
        setState(() {
          _categories = apiCategories
              .map((c) => Category.fromApi(c, productCount: c.productCount))
              .where((c) => c.productCount > 0)
              .toList();
          _products = (paginatedProducts as dynamic).items
              .map<Product>((p) => Product.fromApiSummary(p))
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

  @override
  void dispose() {
    CartManager.instance.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    CartManager.instance.addItem(product);
    AppSnackBar.success(
      context,
      message: '${product.name} añadido al carrito',
      actionLabel: 'Ver carrito',
      onAction: _navigateToCart,
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(currency: widget.selectedCurrency),
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategoryId = null;
                            _selectedSupermarketName = null;
                            _minPrice = 0;
                            _maxPrice = 50;
                            _sortBy = 'Relevancia';
                          });
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ordenar por
                        _buildFilterSection(
                          title: 'Ordenar por',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Relevancia',
                              'Precio: Menor a Mayor',
                              'Precio: Mayor a Menor',
                              'Nombre A-Z',
                            ].map((sort) {
                              final isSelected = _sortBy == sort;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _sortBy = sort;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    sort,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Categoría
                        _buildFilterSection(
                          title: 'Categoría',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((category) {
                              final isSelected =
                                  _selectedCategoryId == category.id;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedCategoryId = isSelected
                                        ? null
                                        : category.id;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? category.color
                                        : AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? category.color
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.black,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Supermercado
                        _buildFilterSection(
                          title: 'Supermercado',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _supermarkets.map((sm) {
                              final isSelected =
                                  _selectedSupermarketName == sm.name;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedSupermarketName =
                                        isSelected ? null : sm.name;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.black,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        sm.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Rango de precio
                        _buildFilterSection(
                          title: 'Rango de Precio (USD)',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '\$${_minPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' - ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '\$${_maxPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              RangeSlider(
                                values: RangeValues(_minPrice, _maxPrice),
                                min: 0,
                                max: 50,
                                divisions: 25,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.lightGrey,
                                labels: RangeLabels(
                                  '\$${_minPrice.toStringAsFixed(0)}',
                                  '\$${_maxPrice.toStringAsFixed(0)}',
                                ),
                                onChanged: (values) {
                                  setModalState(() {
                                    _minPrice = values.start;
                                    _maxPrice = values.end;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final searchText = _searchController.text.trim();
                            _loadData(
                              search: searchText.isEmpty ? null : searchText,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Aplicar Filtros',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightGrey,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            AppHeader(
              selectedCurrency: widget.selectedCurrency,
              onCurrencyChanged: widget.onCurrencyChanged,
              onCartTap: _navigateToCart,
              cartItemCount: CartManager.instance.itemCount,
            ),

            const SizedBox(height: 8),

            // Barra de búsqueda
            _buildSearchBar(),

            const SizedBox(height: 20),

            // Grid de productos
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Todos los Productos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_products.length} productos encontrados',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grid de productos
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: _products[index],
                            currency: widget.selectedCurrency,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: _products[index],
                                    currency: widget.selectedCurrency,
                                  ),
                                ),
                              );
                            },
                            onAddToCart: () {
                              _addToCart(_products[index]);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(
              color: AppColors.grey.withOpacity(0.6),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.grey,
            ),
            suffixIcon: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onPressed: _showFiltersModal,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onSubmitted: (value) {
            _loadData(search: value.trim().isEmpty ? null : value.trim());
          },
        ),
      ),
    );
  }
}
