import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    DateTime? currentDate,
  }) : _currentDate = currentDate;

  final DateTime? _currentDate;

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(_currentDate ?? DateTime.now());
    final weekDates = generateCurrentWeekDates(today);
    final todayLabel = DateFormat('dd MMM').format(today);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weekDates.length, (index) {
            final date = weekDates[index];
            return WeekDayItem(
              date: date,
              isToday: _isSameDay(date, today),
            );
          }),
        ),
        const SizedBox(height: 14),
        Text(
          'Today, $todayLabel',
          style: const TextStyle(
            color: AppColors.rose,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class WeekDayItem extends StatelessWidget {
  const WeekDayItem({
    required this.date,
    required this.isToday,
    super.key,
  });

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(date).substring(0, 2);
    final dayNumber = DateFormat('d').format(date);

    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            color: isToday ? AppColors.rose : AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isToday ? 44 : 34,
          height: isToday ? 44 : 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppColors.rose : Colors.transparent,
            border: isToday
                ? Border.all(color: AppColors.roseLight, width: 5)
                : null,
          ),
          child: Center(
            child: Text(
              dayNumber,
              style: TextStyle(
                color: isToday ? Colors.white : AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<DateTime> generateCurrentWeekDates(DateTime currentDate) {
  final today = _dateOnly(currentDate);
  final monday =
      today.subtract(Duration(days: today.weekday - DateTime.monday));

  return List.generate(
    DateTime.daysPerWeek,
    (index) => monday.add(Duration(days: index)),
  );
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

class CalendarStripExample extends StatelessWidget {
  const CalendarStripExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: CalendarStrip(),
        ),
      ),
    );
  }
}
