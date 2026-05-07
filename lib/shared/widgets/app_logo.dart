import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: -0.65,
        child: Icon(
          Icons.medication_rounded,
          color: Colors.white,
          size: size * 0.48,
        ),
      ),
    );
  }
}
