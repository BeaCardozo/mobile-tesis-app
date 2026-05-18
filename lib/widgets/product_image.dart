import 'dart:convert';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext) errorBuilder;

  const ProductImage({
    super.key,
    required this.url,
    required this.errorBuilder,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma == -1) return errorBuilder(context);
      try {
        final bytes = base64Decode(url.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, _, __) => errorBuilder(ctx),
        );
      } catch (_) {
        return errorBuilder(context);
      }
    }
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (ctx, _, __) => errorBuilder(ctx),
    );
  }
}
