import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum SnackBarType { success, info, error }

class AppSnackBar {
  static _AnimatedSnackBarState? _currentState;
  static Timer? _autoHideTimer;

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Remover notificación anterior inmediatamente
    _removeCurrent();

    final overlay = Overlay.of(context);
    final config = _getConfig(type);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        message: message,
        config: config,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          _autoHideTimer?.cancel();
          _autoHideTimer = null;
          _currentState = null;
          entry.remove();
        },
        onReady: (state) {
          _currentState = state;
        },
      ),
    );

    overlay.insert(entry);

    // Auto-ocultar con animación después de la duración
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(duration, () {
      _currentState?.animateOut();
    });
  }

  static void _removeCurrent() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    if (_currentState != null && _currentState!.mounted) {
      _currentState!.removeImmediately();
    }
    _currentState = null;
  }

  static void success(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarConfig(
          color: AppColors.primary,
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          color: AppColors.accent,
          icon: Icons.info_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarConfig(
          color: AppColors.error,
          icon: Icons.error_rounded,
        );
    }
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final _SnackBarConfig config;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final ValueChanged<_AnimatedSnackBarState> onReady;

  const _AnimatedSnackBar({
    required this.message,
    required this.config,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
    required this.onReady,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();
    widget.onReady(this);
  }

  void removeImmediately() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.stop();
    widget.onDismiss();
  }

  void animateOut() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.config.color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.config.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.config.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onAction != null)
                    GestureDetector(
                      onTap: () {
                        animateOut();
                        widget.onAction!();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  const _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}
