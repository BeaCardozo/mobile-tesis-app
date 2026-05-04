import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/api_models.dart';
import '../models/product.dart';
import '../services/api.dart';
import 'product_detail_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<ApiDeal> _deals = [];
  bool _isLoading = true;
  String? _error;
  String _currency = 'USD';
  String _filterSuper = '';

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final deals = await Api.instance.offers.listDeals(limit: 200);
      if (mounted) {
        setState(() {
          _deals = deals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar ofertas';
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _supermarkets {
    final names = _deals.map((d) => d.supermarketName).toSet().toList();
    names.sort();
    return names;
  }

  List<ApiDeal> get _filteredDeals {
    if (_filterSuper.isEmpty) return _deals;
    return _deals.where((d) => d.supermarketName == _filterSuper).toList();
  }

  String _formatPrice(double usd, double bs) {
    if (_currency == 'Bs') return 'Bs. ${bs.toStringAsFixed(2)}';
    return '\$${usd.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ofertas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      if (!_isLoading)
                        Text(
                          '${_deals.length} producto${_deals.length != 1 ? 's' : ''} en oferta',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                  // Currency toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CurrencyButton(
                          label: '\$ USD',
                          isSelected: _currency == 'USD',
                          onTap: () => setState(() => _currency = 'USD'),
                        ),
                        _CurrencyButton(
                          label: 'Bs',
                          isSelected: _currency == 'Bs',
                          onTap: () => setState(() => _currency = 'Bs'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Supermarket filter chips
            if (!_isLoading && _deals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        isSelected: _filterSuper.isEmpty,
                        onTap: () => setState(() => _filterSuper = ''),
                      ),
                      const SizedBox(width: 8),
                      ..._supermarkets.map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: s,
                              isSelected: _filterSuper == s,
                              onTap: () => setState(() {
                                _filterSuper = _filterSuper == s ? '' : s;
                              }),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _error != null
                      ? _buildError()
                      : _deals.isEmpty
                          ? _buildEmpty()
                          : _buildDealGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withOpacity(0.6)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchDeals,
              child: const Text('Reintentar', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay ofertas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Las ofertas se actualizan automaticamente con cada scraping',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealGrid() {
    final deals = _filteredDeals;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchDeals,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return _DealCard(
            deal: deal,
            currency: _currency,
            formatPrice: _formatPrice,
            onTap: () {
              if (deal.productId != null) {
                final product = Product(
                  id: deal.productId!,
                  name: deal.productName,
                  description: '',
                  imageUrl: deal.imageUrl ?? '',
                  category: '',
                  prices: [
                    PriceInfo(
                      supermarketId: '',
                      supermarketName: deal.supermarketName,
                      supermarketLogo: '',
                      price: deal.priceBs,
                      priceUsd: deal.priceUsd,
                      lastUpdated: DateTime.now(),
                    ),
                  ],
                  averagePrice: deal.priceBs,
                  unit: deal.unitType,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: product,
                      currency: _currency,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _CurrencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final ApiDeal deal;
  final String currency;
  final String Function(double usd, double bs) formatPrice;
  final VoidCallback onTap;

  const _DealCard({
    required this.deal,
    required this.currency,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + discount badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.6),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Center(
                      child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.network(
                                deal.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.shopping_basket_rounded,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.shopping_basket_rounded,
                              size: 40,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                    ),
                  ),
                  // Discount badge
                  if (deal.discountPct > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_down_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '-${deal.discountPct.toStringAsFixed(deal.discountPct % 1 == 0 ? 0 : 1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supermarket name
                    Text(
                      deal.supermarketName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Product name
                    Flexible(
                      child: Text(
                        deal.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Amount + store
                    Text(
                      '${deal.baseAmount % 1 == 0 ? deal.baseAmount.toInt() : deal.baseAmount} ${deal.unitType}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatPrice(deal.priceUsd, deal.priceBs),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (deal.originalPriceUsd != null &&
                            deal.originalPriceUsd! > deal.priceUsd) ...[
                          const SizedBox(width: 6),
                          Text(
                            formatPrice(
                              deal.originalPriceUsd!,
                              deal.originalPriceBs ?? deal.originalPriceUsd! * 80,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey.withOpacity(0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Savings or "En oferta"
                    if (deal.discountPct > 0 &&
                        deal.originalPriceUsd != null)
                      Text(
                        'Ahorras ${formatPrice(deal.originalPriceUsd! - deal.priceUsd, (deal.originalPriceBs ?? 0) - deal.priceBs)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade600,
                        ),
                      )
                    else
                      const Text(
                        'En oferta',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
