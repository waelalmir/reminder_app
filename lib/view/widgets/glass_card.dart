import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double blur; // 0 = بدون تمويه (أخف للقوائم الطويلة)
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 14,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final r = BorderRadius.circular(radius);

    final box = Container(
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .07)
            : Colors.white.withValues(alpha: .72),
        borderRadius: r,
        border: Border.all(
          color: borderColor ??
              (dark
                  ? Colors.white.withValues(alpha: .10)
                  : Colors.white.withValues(alpha: .95)),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (blur <= 0) return box;
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: box,
      ),
    );
  }
}
