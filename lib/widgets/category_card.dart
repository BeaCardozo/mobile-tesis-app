import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final double? iconSize;
  final double? fontSize;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedIconSize = iconSize ?? 24;
    final double resolvedFontSize = fontSize ?? 11;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withOpacity(0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: resolvedIconSize,
                color: category.color,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: resolvedFontSize,
                  fontWeight: FontWeight.w600,
                  color: category.color.withOpacity(0.9),
                  letterSpacing: 0.1,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
