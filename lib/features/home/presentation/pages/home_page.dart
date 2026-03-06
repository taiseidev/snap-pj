import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/photo_provider.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../widgets/focal_length_chart.dart';
import '../widgets/lens_usage_chart.dart';
import '../widgets/recent_activity.dart';

class HomePage extends ConsumerWidget {
  final void Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photoListProvider);
    final favoriteCount = photos.where((p) => p.isFavorite).length;
    final shootingDays = photos.map((p) => _dateKey(p.shotAt)).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShotLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'あなたの撮影カルテ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '総撮影枚数',
                  value: '${photos.length}',
                  icon: Icons.camera_alt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: '撮影日数',
                  value: '$shootingDays',
                  icon: Icons.calendar_today,
                  iconColor: const Color(0xFF16C79A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'お気に入り',
                  value: '$favoriteCount',
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFE94560),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: '平均レーティング',
                  value: _avgRating(photos),
                  icon: Icons.star,
                  iconColor: const Color(0xFFF5A623),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LensUsageChart(photos: photos),
          const SizedBox(height: 12),
          FocalLengthChart(photos: photos),
          const SizedBox(height: 12),
          RecentActivity(
            photos: photos,
            onPhotoTap: (photo) {
              ref.read(selectedPhotoProvider.notifier).state = photo;
              onNavigate(1);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  String _avgRating(List photos) {
    final rated = photos.where((p) => p.rating > 0).toList();
    if (rated.isEmpty) return '-';
    final avg = rated.fold<int>(0, (sum, p) => sum + p.rating as int) /
        rated.length;
    return avg.toStringAsFixed(1);
  }
}
