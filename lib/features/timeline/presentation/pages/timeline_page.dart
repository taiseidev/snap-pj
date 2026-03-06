import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/photo_data.dart';
import '../../../../shared/providers/photo_provider.dart';
import '../../../photo_detail/presentation/pages/photo_detail_page.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final allPhotos = ref.read(photoListProvider);
    final lenses = allPhotos.map((p) => p.lensModel).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(timelineFilterProvider);
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('フィルター',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref.read(timelineFilterProvider.notifier).state =
                              const TimelineFilter();
                          Navigator.pop(context);
                        },
                        child: const Text('リセット'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('並び替え',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('新しい順'),
                        selected: filter.sortOrder == SortOrder.newestFirst,
                        onSelected: (_) {
                          ref.read(timelineFilterProvider.notifier).state =
                              filter.copyWith(sortOrder: SortOrder.newestFirst);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('古い順'),
                        selected: filter.sortOrder == SortOrder.oldestFirst,
                        onSelected: (_) {
                          ref.read(timelineFilterProvider.notifier).state =
                              filter.copyWith(sortOrder: SortOrder.oldestFirst);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('レンズ',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('すべて'),
                        selected: filter.lensModel == null,
                        onSelected: (_) {
                          ref.read(timelineFilterProvider.notifier).state =
                              filter.copyWith(lensModel: () => null);
                        },
                      ),
                      for (final lens in lenses)
                        ChoiceChip(
                          label: Text(_shortLensName(lens)),
                          selected: filter.lensModel == lens,
                          onSelected: (_) {
                            ref.read(timelineFilterProvider.notifier).state =
                                filter.copyWith(lensModel: () => lens);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('焦点距離',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('すべて'),
                        selected: filter.focalLengthRange == null,
                        onSelected: (_) {
                          ref.read(timelineFilterProvider.notifier).state =
                              filter.copyWith(focalLengthRange: () => null);
                        },
                      ),
                      for (final range in [
                        '16-35mm',
                        '36-70mm',
                        '71-135mm',
                        '136mm+'
                      ])
                        ChoiceChip(
                          label: Text(range),
                          selected: filter.focalLengthRange == range,
                          onSelected: (_) {
                            ref.read(timelineFilterProvider.notifier).state =
                                filter.copyWith(
                                    focalLengthRange: () => range);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('お気に入りのみ'),
                    value: filter.favoritesOnly,
                    activeColor: AppTheme.chartColors[0],
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      ref.read(timelineFilterProvider.notifier).state =
                          filter.copyWith(favoritesOnly: value);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _shortLensName(String name) {
    final match = RegExp(r'(\d+-?\d*mm)').firstMatch(name);
    return match?.group(1) ?? name;
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(filteredPhotosProvider);
    final filter = ref.watch(timelineFilterProvider);

    final grouped = <String, List<PhotoData>>{};
    for (final photo in photos) {
      final key = DateFormat('yyyy年M月d日').format(photo.shotAt);
      grouped.putIfAbsent(key, () => []).add(photo);
    }

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'レンズ名、メモで検索...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(timelineFilterProvider.notifier).state =
                      filter.copyWith(searchQuery: value);
                },
              )
            : const Text('タイムライン'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(timelineFilterProvider.notifier).state =
                      filter.copyWith(searchQuery: '');
                }
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (filter.isActive)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE94560),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: photos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    filter.isActive
                        ? '条件に一致する写真がありません'
                        : '写真がまだありません',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (filter.isActive) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(timelineFilterProvider.notifier).state =
                            const TimelineFilter();
                        _searchController.clear();
                        setState(() => _showSearch = false);
                      },
                      child: const Text('フィルターをリセット'),
                    ),
                  ],
                ],
              ),
            )
          : ListView.builder(
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
                              color: AppTheme.chartColors[0]
                                  .withValues(alpha: 0.2),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                builder: (_) =>
                                    PhotoDetailPage(photo: photo),
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
