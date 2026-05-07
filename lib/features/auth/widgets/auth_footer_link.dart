import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.text,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(color: AppColors.muted)),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.rose,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
