import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/photo_provider.dart';
import '../widgets/aperture_distribution.dart';
import '../widgets/insight_card.dart';
import '../widgets/iso_trend_chart.dart';
import '../widgets/lens_detail_section.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(analyticsPhotosProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分析'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'あなたの撮影傾向を分析',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          // Period filter chips
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('全期間'),
                selected: period == AnalyticsPeriod.all,
                onSelected: (_) => ref
                    .read(analyticsPeriodProvider.notifier)
                    .state = AnalyticsPeriod.all,
              ),
              ChoiceChip(
                label: const Text('今月'),
                selected: period == AnalyticsPeriod.thisMonth,
                onSelected: (_) => ref
                    .read(analyticsPeriodProvider.notifier)
                    .state = AnalyticsPeriod.thisMonth,
              ),
              ChoiceChip(
                label: const Text('直近3ヶ月'),
                selected: period == AnalyticsPeriod.threeMonths,
                onSelected: (_) => ref
                    .read(analyticsPeriodProvider.notifier)
                    .state = AnalyticsPeriod.threeMonths,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (photos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.analytics_outlined,
                        size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'この期間の撮影データがありません',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            InsightCard(photos: photos),
            const SizedBox(height: 12),
            ApertureDistribution(photos: photos),
            const SizedBox(height: 12),
            IsoTrendChart(photos: photos),
            const SizedBox(height: 12),
            LensDetailSection(photos: photos),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
