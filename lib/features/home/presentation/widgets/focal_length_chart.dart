import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';

class FocalLengthChart extends StatelessWidget {
  final List<PhotoData> photos;

  const FocalLengthChart({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final ranges = <String, int>{
      '16-35mm': 0,
      '36-70mm': 0,
      '71-135mm': 0,
      '136mm+': 0,
    };

    for (final photo in photos) {
      final fl = photo.focalLength;
      if (fl <= 35) {
        ranges['16-35mm'] = ranges['16-35mm']! + 1;
      } else if (fl <= 70) {
        ranges['36-70mm'] = ranges['36-70mm']! + 1;
      } else if (fl <= 135) {
        ranges['71-135mm'] = ranges['71-135mm']! + 1;
      } else {
        ranges['136mm+'] = ranges['136mm+']! + 1;
      }
    }

    final entries = ranges.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '焦点距離の分布',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: photos.length.toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[idx].key,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white54),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    for (var i = 0; i < entries.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: entries[i].value.toDouble(),
                            color: AppTheme
                                .chartColors[i % AppTheme.chartColors.length],
                            width: 28,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
