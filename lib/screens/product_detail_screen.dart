import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../services/api.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String currency;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.currency = 'Bs',
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoadingPrices = true;
  List<PriceInfo> _allPrices = [];
  String _category = '';

  @override
  void initState() {
    super.initState();
    _allPrices = List.from(widget.product.prices);
    _category = widget.product.category;
    _loadFullDetail();
  }

  Future<void> _loadFullDetail() async {
    try {
      final detail = await Api.instance.products.getDetail(widget.product.id);
      if (!mounted) return;

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
                ? DateTime.tryParse(offer['scraped_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          ));
        }
      }

      setState(() {
        _allPrices = prices;
        _isLoadingPrices = false;
        if (detail.category.name.isNotEmpty) {
          _category = detail.category.name;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPrices = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUsd = widget.currency == 'USD';
    final sortedPrices = List<PriceInfo>.from(_allPrices)
      ..sort((a, b) => isUsd
          ? (a.priceUsd ?? 0).compareTo(b.priceUsd ?? 0)
          : a.price.compareTo(b.price));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
                  child: widget.product.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shopping_basket,
                              size: 120,
                              color: AppColors.primary.withOpacity(0.3),
                            );
                          },
                        )
                      : Icon(
                          Icons.shopping_basket,
                          size: 120,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  if (_category.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nombre del producto
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Descripción
                  if (widget.product.description.isNotEmpty)
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Estadísticas de precio
                  if (sortedPrices.isNotEmpty)
                    _buildPriceStats(sortedPrices),

                  const SizedBox(height: 48),

                  // Título de comparación
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comparación de Precios',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isLoadingPrices
                                  ? 'Cargando precios...'
                                  : '${sortedPrices.length} supermercados disponibles',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_isLoadingPrices)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else
                    // Lista de precios por supermercado
                    ...sortedPrices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final priceInfo = entry.value;
                      final isLowest = index == 0;

                      return _buildPriceCard(priceInfo, isLowest);
                    }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final isUsd = widget.currency == 'USD';
    return isUsd
        ? '\$ ${value.toStringAsFixed(2)}'
        : 'Bs. ${value.toStringAsFixed(2)}';
  }

  double _priceOf(PriceInfo p) {
    return widget.currency == 'USD' ? (p.priceUsd ?? 0) : p.price;
  }

  Widget _buildPriceStats(List<PriceInfo> prices) {
    final lowest = prices.map(_priceOf).reduce((a, b) => a < b ? a : b);
    final highest = prices.map(_priceOf).reduce((a, b) => a > b ? a : b);
    final savings = highest - lowest;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Precio Mínimo',
                  _formatPrice(lowest),
                  Icons.arrow_downward,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Precio Máximo',
                  _formatPrice(highest),
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          if (savings > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Puedes ahorrar hasta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatPrice(savings),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(PriceInfo priceInfo, bool isLowest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLowest
            ? AppColors.primaryLight.withOpacity(0.15)
            : AppColors.lightGrey.withOpacity(0.5),
        border: Border.all(
          color: isLowest
              ? AppColors.primary
              : AppColors.grey.withOpacity(0.15),
          width: isLowest ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isLowest
                ? AppColors.primary.withOpacity(0.12)
                : Colors.black.withOpacity(0.03),
            blurRadius: isLowest ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
            children: [
              // Logo del supermercado
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: priceInfo.supermarketLogo.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          priceInfo.supermarketLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store_rounded,
                              color: AppColors.primary,
                              size: 26,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.store_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
              ),

              const SizedBox(width: 14),

              // Nombre y fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceInfo.supermarketName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.grey.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(priceInfo.lastUpdated),
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

              // Precio
              Text(
                _formatPrice(_priceOf(priceInfo)),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLowest ? AppColors.primary : AppColors.black,
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
