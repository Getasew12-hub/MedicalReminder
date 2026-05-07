import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    required this.selectedDays,
    required this.onChanged,
    super.key,
  });

  final List<String> selectedDays;
  final ValueChanged<List<String>> onChanged;

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: days.map((day) {
        final selected = selectedDays.contains(day);
        return FilterChip(
          selected: selected,
          label: Text(day),
          showCheckmark: false,
          selectedColor: AppColors.rose,
          backgroundColor: AppColors.field,
          side: BorderSide(color: selected ? AppColors.rose : AppColors.line),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w800,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (_) {
            final next = [...selectedDays];
            selected ? next.remove(day) : next.add(day);
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
