import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.line)),
          ],
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(child: _SocialButton(label: 'Google', letter: 'G')),
            SizedBox(width: 12),
            Expanded(child: _SocialButton(label: 'Apple', letter: 'A')),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.letter,
  });

  final String label;
  final String letter;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.roseLight,
            child: Text(
              letter,
              style: const TextStyle(
                color: AppColors.rose,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
