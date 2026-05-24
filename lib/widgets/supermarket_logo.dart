import 'package:flutter/material.dart';
import '../config/app_colors.dart';

String? supermarketLogoAsset(String name) {
  final n = _normalize(name);
  if (n.contains('madeirense')) return 'assets/logos/madeirense.png';
  if (n.contains('gama')) return 'assets/logos/gama.png';
  if (n.contains('plan suarez') || n.contains('suarez')) {
    return 'assets/logos/plan_suarez.png';
  }
  return null;
}

String _normalize(String s) {
  const accents = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n',
    'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u', 'Ñ': 'n',
  };
  final lower = s.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    buf.write(accents[ch] ?? ch);
  }
  return buf.toString();
}

class SupermarketLogo extends StatelessWidget {
  final String name;
  final double size;
  final double borderRadius;

  const SupermarketLogo({
    super.key,
    required this.name,
    this.size = 44,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final asset = supermarketLogoAsset(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: asset != null
          ? Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(),
              ),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Icon(
        Icons.storefront_rounded,
        color: AppColors.primary.withValues(alpha: 0.7),
        size: size * 0.5,
      ),
    );
  }
}
