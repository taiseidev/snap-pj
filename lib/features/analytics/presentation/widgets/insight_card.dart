import 'package:flutter/material.dart';

import '../../../../shared/models/photo_data.dart';

class InsightCard extends StatelessWidget {
  final List<PhotoData> photos;

  const InsightCard({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(photos);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: Color(0xFFF5A623), size: 20),
                const SizedBox(width: 8),
                Text('AI インサイト',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            for (final insight in insights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: insight.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_Insight> _generateInsights(List<PhotoData> photos) {
    final insights = <_Insight>[];

    // Best aperture analysis
    final highRated = photos.where((p) => p.rating >= 4).toList();
    if (highRated.isNotEmpty) {
      final apertureCount = <double, int>{};
      for (final p in highRated) {
        apertureCount[p.aperture] = (apertureCount[p.aperture] ?? 0) + 1;
      }
      final bestAperture =
          apertureCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(_Insight(
        'ベストショットはf/${bestAperture.key}に集中しています。このF値での撮影が得意なようです。',
        const Color(0xFFE94560),
      ));
    }

    // Most used focal length
    final flCount = <double, int>{};
    for (final p in photos) {
      flCount[p.focalLength] = (flCount[p.focalLength] ?? 0) + 1;
    }
    final topFl = flCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    insights.add(_Insight(
      '最も多用する焦点距離は${topFl.key.toInt()}mmです（${topFl.value}枚）。この画角があなたの"目"になりつつあります。',
      const Color(0xFF16C79A),
    ));

    // ISO improvement suggestion
    final highIsoShots = photos.where((p) => p.iso >= 800).length;
    if (highIsoShots > 0) {
      insights.add(_Insight(
        'ISO800以上の撮影が$highIsoShots枚あります。三脚の活用やSSを下げることで、ノイズを抑えた撮影も試してみましょう。',
        const Color(0xFFF5A623),
      ));
    }

    // Favorite lens
    final lensCount = <String, int>{};
    for (final p in photos) {
      lensCount[p.lensModel] = (lensCount[p.lensModel] ?? 0) + 1;
    }
    final topLens =
        lensCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    final lensRatio = (topLens.value / photos.length * 100).round();
    insights.add(_Insight(
      '${topLens.key}の使用率が$lensRatio%を占めています。他のレンズも積極的に使うと表現の幅が広がります。',
      const Color(0xFF50C4ED),
    ));

    return insights;
  }
}

class _Insight {
  final String text;
  final Color color;
  const _Insight(this.text, this.color);
}
