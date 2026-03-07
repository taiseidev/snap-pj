import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/photo_data.dart';

class ShootingCalendar extends StatelessWidget {
  final List<PhotoData> photos;

  const ShootingCalendar({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final shotCounts = <String, int>{};
    for (final photo in photos) {
      final key = _dateKey(photo.shotAt);
      shotCounts[key] = (shotCounts[key] ?? 0) + 1;
    }

    final maxCount =
        shotCounts.values.fold<int>(0, (a, b) => a > b ? a : b).clamp(1, 999);

    // Show 12 weeks (roughly 3 months)
    const weeks = 12;
    // Start from the Monday of (now - 12 weeks)
    final todayWeekday = now.weekday; // 1=Mon, 7=Sun
    final endOfWeek = now.add(Duration(days: 7 - todayWeekday));
    final startDate = endOfWeek.subtract(const Duration(days: 7 * weeks - 1));

    final monthLabels = <_MonthLabel>[];
    int? lastMonth;
    for (int col = 0; col < weeks; col++) {
      final date = startDate.add(Duration(days: col * 7));
      if (date.month != lastMonth) {
        lastMonth = date.month;
        monthLabels.add(_MonthLabel(col: col, label: DateFormat.MMM('ja').format(date)));
      }
    }

    const cellSize = 14.0;
    const cellGap = 3.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Color(0xFFF5A623), size: 20),
                const SizedBox(width: 8),
                Text(
                  '撮影カレンダー',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${shotCounts.length}日撮影',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Month labels
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  // Space for day labels
                  const SizedBox(width: 24),
                  ...List.generate(weeks, (col) {
                    final label = monthLabels
                        .where((m) => m.col == col)
                        .map((m) => m.label)
                        .firstOrNull;
                    return SizedBox(
                      width: cellSize + cellGap,
                      child: label != null
                          ? Text(label,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white38),
                              overflow: TextOverflow.visible,
                              softWrap: false)
                          : null,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Calendar grid: 7 rows (Mon-Sun) x weeks columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                Column(
                  children: List.generate(7, (row) {
                    const labels = ['月', '', '水', '', '金', '', ''];
                    return SizedBox(
                      width: 20,
                      height: cellSize + cellGap,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            labels[row],
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white38),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Grid
                ...List.generate(weeks, (col) {
                  return Column(
                    children: List.generate(7, (row) {
                      final date =
                          startDate.add(Duration(days: col * 7 + row));
                      final count = shotCounts[_dateKey(date)] ?? 0;
                      final isAfterToday = date.isAfter(now);

                      Color cellColor;
                      if (isAfterToday) {
                        cellColor = Colors.transparent;
                      } else if (count == 0) {
                        cellColor = Colors.white.withValues(alpha: 0.06);
                      } else {
                        final intensity = (count / maxCount).clamp(0.0, 1.0);
                        if (intensity <= 0.25) {
                          cellColor = const Color(0xFFE94560).withValues(alpha: 0.25);
                        } else if (intensity <= 0.5) {
                          cellColor = const Color(0xFFE94560).withValues(alpha: 0.5);
                        } else if (intensity <= 0.75) {
                          cellColor = const Color(0xFFE94560).withValues(alpha: 0.75);
                        } else {
                          cellColor = const Color(0xFFE94560);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.all(cellGap / 2),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('少ない',
                    style: TextStyle(fontSize: 10, color: Colors.white38)),
                const SizedBox(width: 4),
                _legendCell(Colors.white.withValues(alpha: 0.06)),
                _legendCell(const Color(0xFFE94560).withValues(alpha: 0.25)),
                _legendCell(const Color(0xFFE94560).withValues(alpha: 0.5)),
                _legendCell(const Color(0xFFE94560).withValues(alpha: 0.75)),
                _legendCell(const Color(0xFFE94560)),
                const SizedBox(width: 4),
                const Text('多い',
                    style: TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendCell(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}

class _MonthLabel {
  final int col;
  final String label;
  const _MonthLabel({required this.col, required this.label});
}
