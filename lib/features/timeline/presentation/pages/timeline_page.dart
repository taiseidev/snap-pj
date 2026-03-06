import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';
import '../../../../shared/providers/photo_provider.dart';
import '../../../photo_detail/presentation/pages/photo_detail_page.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoListProvider);
    final sorted = List<PhotoData>.from(photos)
      ..sort((a, b) => b.shotAt.compareTo(a.shotAt));

    final grouped = <String, List<PhotoData>>{};
    for (final photo in sorted) {
      final key = DateFormat('yyyy年M月d日').format(photo.shotAt);
      grouped.putIfAbsent(key, () => []).add(photo);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final date = grouped.keys.elementAt(index);
          final dayPhotos = grouped[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.chartColors[0].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${dayPhotos.length}枚',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.chartColors[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: dayPhotos.length,
                itemBuilder: (context, photoIndex) {
                  final photo = dayPhotos[photoIndex];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhotoDetailPage(photo: photo),
                        ),
                      );
                    },
                    child: _PhotoTile(photo: photo),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final PhotoData photo;

  const _PhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white10,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: _colorFromFocalLength(photo.focalLength),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_camera,
                        color: Colors.white24, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${photo.focalLength.toInt()}mm',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'f/${photo.aperture}',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ),
          ),
          if (photo.isFavorite)
            const Positioned(
              top: 6,
              right: 6,
              child:
                  Icon(Icons.favorite, color: Color(0xFFE94560), size: 16),
            ),
          if (photo.rating > 0)
            Positioned(
              top: 6,
              left: 6,
              child: Row(
                children: [
                  const Icon(Icons.star,
                      color: Color(0xFFF5A623), size: 12),
                  Text(
                    '${photo.rating}',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFFF5A623)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFromFocalLength(double fl) {
    if (fl <= 35) return const Color(0xFF1A3A5C);
    if (fl <= 70) return const Color(0xFF2A1A4C);
    if (fl <= 135) return const Color(0xFF1A4C3A);
    return const Color(0xFF4C3A1A);
  }
}
