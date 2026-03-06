import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';
import '../../../../shared/providers/photo_provider.dart';

class GearDetailPage extends ConsumerWidget {
  const GearDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoListProvider);
    final cameras = photos.map((p) => p.cameraModel).toSet().toList();
    final lensGroups = <String, List<PhotoData>>{};
    for (final photo in photos) {
      lensGroups.putIfAbsent(photo.lensModel, () => []).add(photo);
    }

    final sortedLenses = lensGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイギア'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Camera section
          Text('カメラ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final camera in cameras)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.chartColors[0].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera,
                          color: Color(0xFFE94560), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            camera,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${photos.where((p) => p.cameraModel == camera).length}枚撮影',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Lens section
          Text('レンズ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var i = 0; i < sortedLenses.length; i++) ...[
            _LensCard(
              lensName: sortedLenses[i].key,
              photos: sortedLenses[i].value,
              totalPhotos: photos.length,
              color: AppTheme.chartColors[i % AppTheme.chartColors.length],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LensCard extends StatelessWidget {
  final String lensName;
  final List<PhotoData> photos;
  final int totalPhotos;
  final Color color;

  const _LensCard({
    required this.lensName,
    required this.photos,
    required this.totalPhotos,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (photos.length / totalPhotos * 100).round();
    final avgIso = photos.fold<int>(0, (s, p) => s + p.iso) ~/ photos.length;
    final ratedPhotos = photos.where((p) => p.rating > 0);
    final avgRating = ratedPhotos.isEmpty
        ? 0.0
        : ratedPhotos.fold<int>(0, (s, p) => s + p.rating) /
            ratedPhotos.length;

    final focalLengths = photos.map((p) => p.focalLength).toSet().toList()
      ..sort();
    final flRange = focalLengths.length == 1
        ? '${focalLengths.first.toInt()}mm'
        : '${focalLengths.first.toInt()}-${focalLengths.last.toInt()}mm';

    final apertures = photos.map((p) => p.aperture).toSet().toList()..sort();
    final favCount = photos.where((p) => p.isFavorite).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                      Text(
                        lensName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '使用率 $ratio%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${photos.length}枚',
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatItem(label: '焦点距離', value: flRange),
                _StatItem(
                    label: '開放F値', value: 'f/${apertures.first}'),
                _StatItem(label: '平均ISO', value: '$avgIso'),
                _StatItem(
                    label: '平均★',
                    value: avgRating > 0
                        ? avgRating.toStringAsFixed(1)
                        : '-'),
              ],
            ),
            if (favCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite,
                      size: 14, color: Color(0xFFE94560)),
                  const SizedBox(width: 4),
                  Text(
                    'お気に入り $favCount枚',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
