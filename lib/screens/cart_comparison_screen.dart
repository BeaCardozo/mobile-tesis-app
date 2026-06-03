import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api.dart';

class CartComparisonScreen extends StatefulWidget {
  final String cartId;
  final String currency;
  final double exchangeRate;
  final int itemCount;

  const CartComparisonScreen({
    super.key,
    required this.cartId,
    required this.currency,
    required this.exchangeRate,
    required this.itemCount,
  });

  @override
  State<CartComparisonScreen> createState() => _CartComparisonScreenState();
}

class _CartComparisonScreenState extends State<CartComparisonScreen> {
  String _mode = 'single';
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    setState(() => _isLoading = true);
    try {
      final data = await Api.instance.carts.compare(
        cartId: widget.cartId,
        mode: _mode,
      );
      if (mounted) setState(() { _data = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _data = null; _isLoading = false; });
    }
  }

  void _switchMode(String mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    _loadComparison();
  }

  double get _effectiveRate {
    final fx = _data?['fxRate'];
    if (fx is Map && fx['rate'] != null) {
      final n = (fx['rate'] as num).toDouble();
      if (n > 0) return n;
    }
    return widget.exchangeRate;
  }

  String _fmt(double usd, {double? bsPrecalc}) {
    if (widget.currency == 'USD') return '\$ ${usd.toStringAsFixed(2)}';
    if (bsPrecalc != null && bsPrecalc.isFinite) {
      return 'Bs. ${bsPrecalc.toStringAsFixed(2)}';
    }
    if (_effectiveRate <= 0) return 'Bs. —';
    return 'Bs. ${(usd * _effectiveRate).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comparación de precios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Toggle de modo
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTab('Un solo super', Icons.store_rounded, 'single'),
                  _buildTab('Mejor precio mixto', Icons.swap_horiz_rounded, 'mixed'),
                ],
              ),
            ),
          ),

          // Descripción del modo
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _mode == 'single'
                  ? 'Compra todo en un solo supermercado al mejor precio total.'
                  : 'Compra cada producto en el supermercado más barato.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _data != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _mode == 'single'
                            ? _buildSingle()
                            : _buildMixed(),
                      )
                    : _buildError(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, String mode) {
    final isActive = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isActive ? AppColors.primary : AppColors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar la comparación',
            style: TextStyle(fontSize: 14, color: AppColors.grey.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadComparison,
            child: const Text('Reintentar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Single
  // ---------------------------------------------------------------------------

  Widget _buildSingle() {
    if (_data!.containsKey('message')) {
      return _msgCard(_data!['message'] as String);
    }

    final cheapest = _data!['cheapest'] as Map<String, dynamic>?;

    final supermarkets = List<dynamic>.from(_data!['supermarkets'] as List<dynamic>? ?? []);

    if (supermarkets.isEmpty) return _msgCard('No hay precios disponibles');

    // La "Mejor opción" siempre se lista de primero.
    if (cheapest != null) {
      final bestName = cheapest['name'];
      final bestIdx = supermarkets.indexWhere(
        (s) => (s as Map<String, dynamic>)['name'] == bestName,
      );
      if (bestIdx > 0) {
        final best = supermarkets.removeAt(bestIdx);
        supermarkets.insert(0, best);
      }
    }

    return Column(
      children: [
        ...supermarkets.asMap().entries.map((entry) {
          final idx = entry.key;
          final sm = entry.value as Map<String, dynamic>;
          final name = sm['name'] as String? ?? '';
          final totalUsd = (sm['totalUsd'] as num?)?.toDouble() ?? 0;
          final totalBs = (sm['totalBs'] as num?)?.toDouble();
          final allAvailable = sm['allProductsAvailable'] as bool? ?? false;
          final lines = sm['lines'] as List<dynamic>? ?? [];
          final isBest = cheapest != null && cheapest['name'] == name;
          final available = lines.where((l) => (l as Map<String, dynamic>)['available'] == true).length;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBest && allAvailable
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.1),
                width: isBest && allAvailable ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.grey.withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
                            Text(
                              '$available/${widget.itemCount} productos disponibles',
                              style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _fmt(totalUsd, bsPrecalc: totalBs),
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold,
                              color: isBest && allAvailable ? AppColors.primary : AppColors.black,
                            ),
                          ),
                          if (isBest && allAvailable)
                            _badge('Mejor opción', AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
                          if (!allAvailable)
                            _badge('Incompleto', Colors.amber.withValues(alpha: 0.1), Colors.amber.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
                // Line breakdown
                if (lines.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.grey.withValues(alpha: 0.08))),
                    ),
                    child: Column(
                      children: lines.map((l) {
                        final line = l as Map<String, dynamic>;
                        final pName = line['productName'] as String? ?? '';
                        final qty = line['quantity'] as int? ?? 1;
                        final avail = line['available'] as bool? ?? false;
                        final lineUsd = (line['lineTotalUsd'] as num?)?.toDouble();
                        final lineBs = (line['lineTotalBs'] as num?)?.toDouble();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$pName x$qty',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: avail ? AppColors.black.withValues(alpha: 0.7) : AppColors.grey.withValues(alpha: 0.4),
                                    decoration: avail ? null : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                lineUsd != null ? _fmt(lineUsd, bsPrecalc: lineBs) : 'N/D',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: avail ? AppColors.black.withValues(alpha: 0.8) : AppColors.grey.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }),

        // Savings
        if (supermarkets.length > 1) _buildSavings(supermarkets),
      ],
    );
  }

  Widget _buildSavings(List<dynamic> supermarkets) {
    final totals = supermarkets
        .map((s) => ((s as Map<String, dynamic>)['totalUsd'] as num?)?.toDouble() ?? 0)
        .toList();
    final savings = totals.reduce((a, b) => a > b ? a : b) - totals.reduce((a, b) => a < b ? a : b);
    if (savings <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.savings_outlined, size: 18, color: AppColors.primary.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ahorras hasta ${_fmt(savings)} eligiendo el supermercado más barato',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mixed
  // ---------------------------------------------------------------------------

  Widget _buildMixed() {
    if (_data!.containsKey('message')) {
      return _msgCard(_data!['message'] as String);
    }

    final grandTotal = (_data!['grandTotalUsd'] as num?)?.toDouble() ?? 0;
    final grandTotalBs = (_data!['grandTotalBs'] as num?)?.toDouble();
    final bySupermarket = _data!['bySupermarket'] as List<dynamic>? ?? [];

    if (bySupermarket.isEmpty) return _msgCard('No hay precios disponibles');

    return Column(
      children: [
        // Total card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Compra optimizada', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
                    Text(
                      'Comprar en ${bySupermarket.length} supermercado${bySupermarket.length == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt(grandTotal, bsPrecalc: grandTotalBs), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Text('Total optimizado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Supermarket cards
        ...bySupermarket.map((entry) {
          final s = entry as Map<String, dynamic>;
          final name = s['supermarketName'] as String? ?? '';
          final subtotal = (s['subtotalUsd'] as num?)?.toDouble() ?? 0;
          final subtotalBs = (s['subtotalBs'] as num?)?.toDouble();
          final purchases = s['purchases'] as List<dynamic>? ?? [];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black)),
                            Text(
                              '${purchases.length} producto${purchases.length == 1 ? '' : 's'}',
                              style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Text(_fmt(subtotal, bsPrecalc: subtotalBs), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                    ],
                  ),
                ),
                if (purchases.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.grey.withValues(alpha: 0.08))),
                    ),
                    child: Column(
                      children: purchases.map((p) {
                        final purchase = p as Map<String, dynamic>;
                        final pName = purchase['productName'] as String? ?? '';
                        final unitUsd = (purchase['unitPriceUsd'] as num?)?.toDouble() ?? 0;
                        final unitBs = (purchase['unitPriceBs'] as num?)?.toDouble();
                        final qty = purchase['quantity'] as int? ?? 1;
                        final lineUsd = (purchase['lineTotalUsd'] as num?)?.toDouble() ?? 0;
                        final lineBs = (purchase['lineTotalBs'] as num?)?.toDouble();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 26, height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Icon(Icons.shopping_basket_rounded, size: 12, color: AppColors.primary.withValues(alpha: 0.4)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, color: AppColors.black.withValues(alpha: 0.7))),
                                    Text('${_fmt(unitUsd, bsPrecalc: unitBs)} x $qty',
                                        style: TextStyle(fontSize: 10, color: AppColors.grey.withValues(alpha: 0.5))),
                                  ],
                                ),
                              ),
                              Text(_fmt(lineUsd, bsPrecalc: lineBs), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black.withValues(alpha: 0.8))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }),

        // Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Precio optimizado comprando cada producto donde sea más barato',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.accent.withValues(alpha: 0.9)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _msgCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(msg, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.grey.withValues(alpha: 0.6))),
    );
  }
}
