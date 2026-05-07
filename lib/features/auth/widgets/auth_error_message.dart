import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({
    required this.message,
    super.key,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final errorMessage = message;
    if (errorMessage == null || errorMessage.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        border: Border.all(color: const Color(0x47E91E63)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.roseDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
