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
    final photos = ref.watch(photoListProvider);

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
          const SizedBox(height: 20),
          InsightCard(photos: photos),
          const SizedBox(height: 12),
          ApertureDistribution(photos: photos),
          const SizedBox(height: 12),
          IsoTrendChart(photos: photos),
          const SizedBox(height: 12),
          LensDetailSection(photos: photos),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
