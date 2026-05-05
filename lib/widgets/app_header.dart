import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'cart_button.dart';

class AppHeader extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onCartTap;
  final int cartItemCount;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const AppHeader({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onCartTap,
    required this.cartItemCount,
    this.onNotificationTap,
    this.notificationCount = 0,
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
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Caracas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextSpan(
                      text: 'Ahorra',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Compara y ahorra',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey.withOpacity(0.7),
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
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  icon: Icon(
                    Icons.unfold_more_rounded,
                    size: 14,
                    color: AppColors.primary.withOpacity(0.7),
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

              // Botón de notificaciones
              if (onNotificationTap != null)
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              notificationCount > 9
                                  ? '9+'
                                  : notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              if (onNotificationTap != null) const SizedBox(width: 10),

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
