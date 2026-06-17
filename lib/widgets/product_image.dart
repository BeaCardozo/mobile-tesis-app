import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Muestra la imagen de un producto. Acepta tanto URLs `http(s)` como
/// data URLs en base64 (`data:image/...;base64,...`).
///
/// Es un [StatefulWidget] para decodificar el base64 una sola vez y reutilizar
/// el mismo [ImageProvider] entre rebuilds. Si se decodificara en cada build,
/// cada `Uint8List` nuevo invalidaría el caché de imágenes y la foto se
/// re-decodificaría/parpadearía en cada `setState` (cambio de moneda, carrito,
/// scroll, etc.).
class ProductImage extends StatefulWidget {
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
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  // Provider estable cacheado. Se recalcula solo si cambia la url.
  ImageProvider? _provider;
  bool _decodeFailed = false;

  @override
  void initState() {
    super.initState();
    _buildProvider();
  }

  @override
  void didUpdateWidget(ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _buildProvider();
    }
  }

  void _buildProvider() {
    _decodeFailed = false;
    final url = widget.url;

    if (url.isEmpty) {
      _provider = null;
      return;
    }

    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma == -1) {
        _provider = null;
        _decodeFailed = true;
        return;
      }
      try {
        final Uint8List bytes = base64Decode(url.substring(comma + 1));
        _provider = MemoryImage(bytes);
      } catch (_) {
        _provider = null;
        _decodeFailed = true;
      }
      return;
    }

    _provider = NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null || _decodeFailed) {
      return widget.errorBuilder(context);
    }

    return Image(
      image: _provider!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      // Mantiene la imagen anterior visible mientras se resuelve, sin parpadeo.
      gaplessPlayback: true,
      errorBuilder: (ctx, _, __) => widget.errorBuilder(ctx),
    );
  }
}
