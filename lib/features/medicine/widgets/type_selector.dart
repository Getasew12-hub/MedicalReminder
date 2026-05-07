import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/medicine.dart';

class TypeSelector extends StatelessWidget {
  const TypeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final MedicineType selected;
  final ValueChanged<MedicineType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MedicineType.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == MedicineType.values.last ? 0 : 10,
            ),
            child: InkWell(
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.rose : AppColors.field,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.rose : AppColors.line,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? Colors.white : AppColors.muted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
