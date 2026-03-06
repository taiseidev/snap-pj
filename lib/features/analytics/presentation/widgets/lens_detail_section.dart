import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';

class LensDetailSection extends StatelessWidget {
  final List<PhotoData> photos;

  const LensDetailSection({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final lensGroups = <String, List<PhotoData>>{};
    for (final photo in photos) {
      lensGroups.putIfAbsent(photo.lensModel, () => []).add(photo);
    }

    final sorted = lensGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('レンズ別分析',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < sorted.length; i++) ...[
              _LensRow(
                lensName: sorted[i].key,
                photos: sorted[i].value,
                color: AppTheme.chartColors[i % AppTheme.chartColors.length],
                totalPhotos: photos.length,
              ),
              if (i < sorted.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _LensRow extends StatelessWidget {
  final String lensName;
  final List<PhotoData> photos;
  final Color color;
  final int totalPhotos;

  const _LensRow({
    required this.lensName,
    required this.photos,
    required this.color,
    required this.totalPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final avgRating = photos.where((p) => p.rating > 0).isEmpty
        ? 0.0
        : photos.where((p) => p.rating > 0).fold<int>(0, (s, p) => s + p.rating) /
            photos.where((p) => p.rating > 0).length;

    final avgIso =
        photos.fold<int>(0, (s, p) => s + p.iso) ~/ photos.length;

    final ratio = (photos.length / totalPhotos * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lensName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                  Text(
                    '${photos.length}枚 ($ratio%)  |  平均ISO: $avgIso  |  平均★: ${avgRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
