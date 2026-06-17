import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/product.dart';
import '../services/api.dart';
import '../widgets/product_image.dart';
import '../widgets/supermarket_logo.dart';

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
  double? _fxRate;

  @override
  void initState() {
    super.initState();
    _allPrices = List.from(widget.product.prices);
    _category = widget.product.category;
    _loadFullDetail();
    _loadFxRate();
  }

  Future<void> _loadFxRate() async {
    final r = await Api.instance.meta.fxUsdToBs();
    if (!mounted) return;
    setState(() => _fxRate = r);
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
      backgroundColor: AppColors.backgroundSoftGreen,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundSoftGreen,
            elevation: 0,
            leadingWidth: 120,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Volver',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: const [
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(48, 72, 48, 32),
                child: widget.product.imageUrl.isNotEmpty
                    ? ProductImage(
                        url: widget.product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_) => Icon(
                          Icons.shopping_basket,
                          size: 120,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      )
                    : Icon(
                        Icons.shopping_basket,
                        size: 120,
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
                        color: AppColors.primaryLight.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _category,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Nombre del producto
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Descripción
                  if (widget.product.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Estadísticas de precio
                  if (sortedPrices.isNotEmpty)
                    _buildPriceStats(sortedPrices),

                  const SizedBox(height: 36),

                  // Título de comparación
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Comparación de precios',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      _isLoadingPrices
                          ? 'Cargando precios...'
                          : '${sortedPrices.length} supermercado${sortedPrices.length == 1 ? '' : 's'} disponible${sortedPrices.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey.withValues(alpha: 0.75),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

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
                      final isLast = index == sortedPrices.length - 1;

                      return _buildPriceRow(priceInfo, isLowest, isLast);
                    }),

                  // Tasa BCV de referencia
                  if (_fxRate != null && _fxRate! > 0) ...[
                    const SizedBox(height: 24),
                    _buildBcvRateFooter(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBcvRateFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.currency_exchange_rounded,
          size: 14,
          color: AppColors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          'Tasa BCV de referencia: Bs. ${_fxRate!.toStringAsFixed(2)} / USD',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
            letterSpacing: 0.1,
          ),
        ),
      ],
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
    final hasRange = highest > lowest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatPill(
                label: 'Mínimo',
                value: _formatPrice(lowest),
                color: AppColors.primary,
                background: AppColors.primaryLight.withValues(alpha: 0.18),
                emphasized: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatPill(
                label: hasRange ? 'Máximo' : 'Único disponible',
                value: _formatPrice(highest),
                color: AppColors.grey,
                background: AppColors.lightGrey,
                emphasized: false,
              ),
            ),
          ],
        ),
        if (savings > 0) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puedes ahorrar hasta',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.grey.withValues(alpha: 0.85),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPrice(savings),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
    required Color background,
    required bool emphasized,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: emphasized
                  ? AppColors.primaryDark.withValues(alpha: 0.75)
                  : AppColors.grey,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: emphasized ? color : AppColors.black,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(PriceInfo priceInfo, bool isLowest, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLowest ? 6 : 0),
      padding: EdgeInsets.fromLTRB(
        isLowest ? 14 : 4,
        14,
        isLowest ? 14 : 4,
        14,
      ),
      decoration: BoxDecoration(
        color: isLowest
            ? AppColors.primaryLight.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: isLowest ? BorderRadius.circular(16) : null,
        border: (isLast || isLowest)
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo del supermercado
          SupermarketLogo(name: priceInfo.supermarketName),

          const SizedBox(width: 14),

          // Nombre, badge y fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        priceInfo.supermarketName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          letterSpacing: -0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLowest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Mejor precio',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(priceInfo.lastUpdated),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(_priceOf(priceInfo)),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isLowest ? AppColors.primary : AppColors.black,
                  letterSpacing: -0.3,
                ),
              ),
            ],
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
