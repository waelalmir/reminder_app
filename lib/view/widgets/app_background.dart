import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  Widget _blob(Color c, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark ? AppColors.darkBg : AppColors.lightBg,
            ),
          ),
        ),
        Positioned(
            top: -90,
            left: -70,
            child: _blob(AppColors.seed.withValues(alpha: dark ? .35 : .22), 300)),
        Positioned(
            bottom: -110,
            right: -80,
            child: _blob(AppColors.accent.withValues(alpha: dark ? .30 : .18), 320)),
        child,
      ],
    );
  }
}
