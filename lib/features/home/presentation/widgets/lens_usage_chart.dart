import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';

class LensUsageChart extends StatelessWidget {
  final List<PhotoData> photos;

  const LensUsageChart({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final lensCount = <String, int>{};
    for (final photo in photos) {
      final short = _shortenLensName(photo.lensModel);
      lensCount[short] = (lensCount[short] ?? 0) + 1;
    }

    final sorted = lensCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'レンズ使用率',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          for (var i = 0; i < sorted.length; i++)
                            PieChartSectionData(
                              value: sorted[i].value.toDouble(),
                              color: AppTheme
                                  .chartColors[i % AppTheme.chartColors.length],
                              radius: 40,
                              title:
                                  '${(sorted[i].value / photos.length * 100).round()}%',
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < sorted.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppTheme.chartColors[
                                      i % AppTheme.chartColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                sorted[i].key,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortenLensName(String name) {
    return name
        .replaceAll('FE ', '')
        .replaceAll(' GM II', ' GM2')
        .replaceAll(' GM', ' GM');
  }
}
