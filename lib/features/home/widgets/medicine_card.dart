import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/medicine/models/medicine.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    required this.medicine,
    required this.onDone,
    required this.onSkip,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Medicine medicine;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isFeatured = !medicine.isDone && !medicine.isSkipped;
    final background = isFeatured ? AppColors.primaryGradient : null;
    final foreground = isFeatured ? Colors.white : AppColors.ink;
    final secondary = isFeatured ? Colors.white70 : AppColors.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: background,
        color: isFeatured ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: isFeatured ? 0.18 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isFeatured
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.roseLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  medicine.type.icon,
                  color: isFeatured ? Colors.white : AppColors.rose,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.dosage} | ${medicine.type.label}',
                      style: TextStyle(color: secondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      medicine.time.format(context),
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: secondary),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  label: 'Skip',
                  icon: Icons.close_rounded,
                  foreground: foreground,
                  onTap: onSkip,
                ),
              ),
              Container(
                height: 22,
                width: 1,
                color: isFeatured ? Colors.white24 : AppColors.line,
              ),
              Expanded(
                child: _CardAction(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  foreground: foreground,
                  onTap: onDone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
