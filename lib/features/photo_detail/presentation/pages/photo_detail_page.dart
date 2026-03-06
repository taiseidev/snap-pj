import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';
import '../../../../shared/providers/photo_provider.dart';

class PhotoDetailPage extends ConsumerStatefulWidget {
  final PhotoData photo;

  const PhotoDetailPage({super.key, required this.photo});

  @override
  ConsumerState<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends ConsumerState<PhotoDetailPage> {
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.photo.memo ?? '');
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(photoListProvider);
    final photo = photos.firstWhere((p) => p.id == widget.photo.id,
        orElse: () => widget.photo);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('写真詳細'),
        actions: [
          IconButton(
            icon: Icon(
              photo.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: photo.isFavorite ? AppTheme.chartColors[0] : null,
            ),
            onPressed: () {
              ref
                  .read(photoListProvider.notifier)
                  .toggleFavorite(photo.id);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Photo preview area
          Container(
            height: 280,
            color: _colorFromFocalLength(photo.focalLength),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera,
                      color: Colors.white24, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    '${photo.focalLength.toInt()}mm  f/${photo.aperture}',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                Row(
                  children: [
                    Text('レーティング', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    for (var i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(photoListProvider.notifier)
                              .updateRating(photo.id, i);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            i <= photo.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppTheme.ratingColor,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // EXIF Info
                Text('撮影データ', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _ExifGrid(photo: photo),
                const SizedBox(height: 20),

                // Memo
                Text('撮影メモ', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _memoController,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '撮影時の意図や反省点を記録...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(photoListProvider.notifier)
                        .updateMemo(photo.id, value);
                  },
                ),
                const SizedBox(height: 32),
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

class _ExifGrid extends StatelessWidget {
  final PhotoData photo;

  const _ExifGrid({required this.photo});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ExifItem(Icons.camera, 'カメラ', photo.cameraModel),
      _ExifItem(Icons.lens, 'レンズ', photo.lensModel),
      _ExifItem(Icons.straighten, '焦点距離', '${photo.focalLength.toInt()}mm'),
      _ExifItem(Icons.camera_alt, 'F値', 'f/${photo.aperture}'),
      _ExifItem(Icons.shutter_speed, 'SS', '${photo.shutterSpeed}s'),
      _ExifItem(Icons.iso, 'ISO', '${photo.iso}'),
      _ExifItem(Icons.access_time,
          '撮影日時', DateFormat('yyyy/M/d HH:mm').format(photo.shotAt)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(items[i].icon, size: 18, color: Colors.white38),
                  const SizedBox(width: 12),
                  Text(
                    items[i].label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      items[i].value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ExifItem {
  final IconData icon;
  final String label;
  final String value;
  const _ExifItem(this.icon, this.label, this.value);
}
