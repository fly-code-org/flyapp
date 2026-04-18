import 'package:flutter/material.dart';

/// Daily.dev–style week dots from current streak + last engagement (no server history).
void showStreakDetailSheet(
  BuildContext context, {
  required int streakCount,
  required DateTime? lastEngagedAt,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.paddingOf(ctx).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$streakCount day streak',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'One meaningful action each local calendar day keeps your streak. '
              'If you miss a day, you start again at day 1.',
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This week',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _WeekDots(
              streakCount: streakCount,
              lastEngagedAt: lastEngagedAt,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _WeekDots extends StatelessWidget {
  final int streakCount;
  final DateTime? lastEngagedAt;

  const _WeekDots({
    required this.streakCount,
    required this.lastEngagedAt,
  });

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static DateTime _mondayOfWeekContaining(DateTime d) {
    final day = _dateOnly(d);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = _mondayOfWeekContaining(now);
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final Set<DateTime> filled = {};
    if (lastEngagedAt != null && streakCount > 0) {
      final lastDay = _dateOnly(lastEngagedAt!.toLocal());
      for (var i = 0; i < streakCount; i++) {
        filled.add(lastDay.subtract(Duration(days: i)));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        final isFilled = filled.contains(day);
        final isToday = day == _dateOnly(now);

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? Colors.deepPurple.shade100
                    : Colors.grey.shade200,
                border: Border.all(
                  color: isToday ? Colors.deepPurple : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: isFilled
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: Colors.deepPurple.shade800,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
