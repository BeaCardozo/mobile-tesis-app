import 'package:flutter/material.dart';
import '../config/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: 'Ahorra',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: -0.3,
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
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.grey.withOpacity(0.7),
                  ),
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    letterSpacing: 0.2,
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

              const SizedBox(width: 12),

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
