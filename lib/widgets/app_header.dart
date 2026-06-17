import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'app_brand_logo.dart';
import 'cart_button.dart';

class AppHeader extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onCartTap;
  final int cartItemCount;

  const AppHeader({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onCartTap,
    required this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre de la app + tagline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppBrandLogo(),
              const SizedBox(height: 2),
              Text(
                'Compara y ahorra',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey.withValues(alpha: 0.7),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),

          // Controles
          Row(
            children: [

              // Selector de moneda
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  icon: Icon(
                    Icons.unfold_more_rounded,
                    size: 14,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
                      onCurrencyChanged(newValue);
                    }
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Botón del carrito
              CartButton(
                onTap: onCartTap,
                itemCount: cartItemCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
