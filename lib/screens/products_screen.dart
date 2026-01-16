import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_button.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<CartItem> _cartItems = [];

  // Filtros
  String? _selectedCategory;
  String? _selectedSupermarket;
  double _minPrice = 0;
  double _maxPrice = 100;
  String _sortBy = 'Relevancia';

  // Moneda seleccionada
  String _selectedCurrency = 'Bs';

  // Categorías (para los filtros)
  final List<Category> _categories = [
    Category(
      id: '1',
      name: 'Alimentos',
      icon: Icons.restaurant,
      color: AppColors.primary,
    ),
    Category(
      id: '2',
      name: 'Bebidas',
      icon: Icons.local_drink,
      color: const Color(0xFF5B9BD5),
    ),
    Category(
      id: '3',
      name: 'Limpieza',
      icon: Icons.cleaning_services,
      color: const Color(0xFFB97FB9),
    ),
    Category(
      id: '4',
      name: 'Cuidado Personal',
      icon: Icons.self_improvement,
      color: const Color(0xFFED7D95),
    ),
    Category(
      id: '5',
      name: 'Mascotas',
      icon: Icons.pets,
      color: AppColors.accent,
    ),
  ];

  // Datos de ejemplo - Estos vendrán del backend
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Arroz Diana 1kg',
      description: 'Arroz blanco de grano largo, calidad premium',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 3.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 3.20,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 3.45,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '3',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 3.80,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '2',
      name: 'Aceite Mazeite 1L',
      description: 'Aceite vegetal 100% puro',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'L',
      averagePrice: 4.25,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 4.10,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 4.40,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '3',
      name: 'Harina PAN 1kg',
      description: 'Harina de maíz precocida',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 2.80,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 2.65,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Automercado',
          supermarketLogo: '',
          price: 2.95,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
    Product(
      id: '4',
      name: 'Azúcar Blanca 1kg',
      description: 'Azúcar refinada',
      imageUrl: '',
      category: 'Alimentos',
      unit: 'kg',
      averagePrice: 1.50,
      prices: [
        PriceInfo(
          supermarketId: '1',
          supermarketName: 'Excelsior Gama',
          supermarketLogo: '',
          price: 1.45,
          lastUpdated: DateTime.now(),
        ),
        PriceInfo(
          supermarketId: '2',
          supermarketName: 'Central Madeirense',
          supermarketLogo: '',
          price: 1.55,
          lastUpdated: DateTime.now(),
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final defaultSupermarketId = product.prices.isNotEmpty
        ? product.prices.first.supermarketId
        : '';

    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex != -1) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(
          CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            product: product,
            quantity: 1,
            selectedSupermarketId: defaultSupermarketId,
            addedAt: DateTime.now(),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            _navigateToCart();
          },
        ),
      ),
    );
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _updateCartItemQuantity(String itemId, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: _cartItems,
          onRemoveItem: _removeFromCart,
          onUpdateQuantity: _updateCartItemQuantity,
        ),
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
                            _selectedCategory = null;
                            _selectedSupermarket = null;
                            _minPrice = 0;
                            _maxPrice = 100;
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
                                  _selectedCategory == category.name;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedCategory = isSelected
                                        ? null
                                        : category.name;
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
                          child: Column(
                            children: [
                              'Excelsior Gama',
                              'Central Madeirense',
                              'Automercado',
                              'Unicasa',
                            ].map((supermarket) {
                              final isSelected =
                                  _selectedSupermarket == supermarket;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.lightGrey,
                                  leading: Icon(
                                    Icons.store_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey,
                                  ),
                                  title: Text(
                                    supermarket,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setModalState(() {
                                      _selectedSupermarket = isSelected
                                          ? null
                                          : supermarket;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Rango de precio
                        _buildFilterSection(
                          title: 'Rango de Precio (Bs.)',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bs. ${_minPrice.toStringAsFixed(0)}',
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
                                      'Bs. ${_maxPrice.toStringAsFixed(0)}',
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
                                max: 100,
                                divisions: 20,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.lightGrey,
                                labels: RangeLabels(
                                  'Bs. ${_minPrice.toStringAsFixed(0)}',
                                  'Bs. ${_maxPrice.toStringAsFixed(0)}',
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
                            setState(() {
                              // Aplicar filtros
                              // TODO: Filtrar productos según los criterios seleccionados
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Filtros aplicados'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
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
            _buildHeader(),

            const SizedBox(height: 8),

            // Barra de búsqueda
            _buildSearchBar(),

            const SizedBox(height: 20),

            // Grid de productos
            Expanded(
              child: SingleChildScrollView(
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: _products[index],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Caracas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: 'Ahorra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Controles de moneda y carrito
          Row(
            children: [
              // Dropdown de moneda
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Bs',
                      child: Text('Bs'),
                    ),
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('USD'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Botón del carrito
              CartButton(
                onTap: _navigateToCart,
                itemCount: _cartItems.length,
              ),
            ],
          ),
        ],
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
            // TODO: Implementar búsqueda
          },
        ),
      ),
    );
  }
}
