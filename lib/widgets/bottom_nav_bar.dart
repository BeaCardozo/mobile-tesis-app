import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = AlwaysStoppedAnimation(widget.currentIndex.toDouble());
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animation = Tween<double>(
        begin: oldWidget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int itemCount = 4;
    const double indicatorSize = 34.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / itemCount;

                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final double animValue = _animation.value;

                    return Stack(
                      children: [
                        // Indicador deslizante
                        Positioned(
                          left: animValue * itemWidth +
                              (itemWidth - indicatorSize) / 2,
                          top: 0,
                          child: Container(
                            width: indicatorSize,
                            height: indicatorSize,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        // Items de navegación
                        Row(
                          children: [
                            _buildNavItem(
                              icon: Icons.home_rounded,
                              label: 'Inicio',
                              index: 0,
                              animValue: animValue,
                            ),
                            _buildNavItem(
                              icon: Icons.shopping_bag_rounded,
                              label: 'Productos',
                              index: 1,
                              animValue: animValue,
                            ),
                            _buildNavItem(
                              icon: Icons.local_offer_rounded,
                              label: 'Ofertas',
                              index: 2,
                              animValue: animValue,
                            ),
                            _buildNavItem(
                              icon: Icons.person_rounded,
                              label: 'Perfil',
                              index: 3,
                              animValue: animValue,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required double animValue,
  }) {
    final double distance = (animValue - index).abs();
    final double activity = (1.0 - distance).clamp(0.0, 1.0);

    final color = Color.lerp(
      AppColors.grey.withOpacity(0.7),
      AppColors.primary,
      activity,
    )!;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 34,
              width: 34,
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: activity > 0.5 ? FontWeight.w500 : FontWeight.w400,
                color: color,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
