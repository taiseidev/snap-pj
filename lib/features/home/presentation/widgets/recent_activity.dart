import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/photo_data.dart';

class RecentActivity extends StatelessWidget {
  final List<PhotoData> photos;
  final void Function(PhotoData) onPhotoTap;

  const RecentActivity({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final recent = List<PhotoData>.from(photos)
      ..sort((a, b) => b.shotAt.compareTo(a.shotAt));
    final display = recent.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近の撮影',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final photo in display)
              InkWell(
                onTap: () => onPhotoTap(photo),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white10,
                        ),
                        child: const Icon(
                          Icons.photo,
                          color: Colors.white24,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('M/d (E)', 'ja')
                                  .format(photo.shotAt),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${photo.lensModel}  ${photo.focalLength.toInt()}mm  f/${photo.aperture}  ISO${photo.iso}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (photo.isFavorite)
                        const Icon(Icons.favorite,
                            color: Color(0xFFE94560), size: 16),
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
