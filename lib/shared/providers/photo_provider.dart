import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mock_data.dart';
import '../models/photo_data.dart';

final photoListProvider =
    StateNotifierProvider<PhotoListNotifier, List<PhotoData>>(
        (ref) => PhotoListNotifier());

class PhotoListNotifier extends StateNotifier<List<PhotoData>> {
  PhotoListNotifier() : super(List.from(mockPhotos));

  void updateRating(String id, int rating) {
    state = [
      for (final photo in state)
        if (photo.id == id) photo.copyWith(rating: rating) else photo,
    ];
  }

  void toggleFavorite(String id) {
    state = [
      for (final photo in state)
        if (photo.id == id)
          photo.copyWith(isFavorite: !photo.isFavorite)
        else
          photo,
    ];
  }

  void updateMemo(String id, String memo) {
    state = [
      for (final photo in state)
        if (photo.id == id) photo.copyWith(memo: memo) else photo,
    ];
  }

  void deletePhoto(String id) {
    state = state.where((photo) => photo.id != id).toList();
  }
}

final selectedPhotoProvider = StateProvider<PhotoData?>((ref) => null);

// Timeline filter state
enum SortOrder { newestFirst, oldestFirst }

class TimelineFilter {
  final String? lensModel;
  final String? focalLengthRange;
  final bool favoritesOnly;
  final SortOrder sortOrder;
  final String searchQuery;

  const TimelineFilter({
    this.lensModel,
    this.focalLengthRange,
    this.favoritesOnly = false,
    this.sortOrder = SortOrder.newestFirst,
    this.searchQuery = '',
  });

  TimelineFilter copyWith({
    String? Function()? lensModel,
    String? Function()? focalLengthRange,
    bool? favoritesOnly,
    SortOrder? sortOrder,
    String? searchQuery,
  }) {
    return TimelineFilter(
      lensModel: lensModel != null ? lensModel() : this.lensModel,
      focalLengthRange:
          focalLengthRange != null ? focalLengthRange() : this.focalLengthRange,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isActive =>
      lensModel != null ||
      focalLengthRange != null ||
      favoritesOnly ||
      searchQuery.isNotEmpty;
}

final timelineFilterProvider =
    StateProvider<TimelineFilter>((ref) => const TimelineFilter());

final filteredPhotosProvider = Provider<List<PhotoData>>((ref) {
  final photos = ref.watch(photoListProvider);
  final filter = ref.watch(timelineFilterProvider);

  var result = List<PhotoData>.from(photos);

  // Search query
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    result = result.where((p) {
      return p.cameraModel.toLowerCase().contains(query) ||
          p.lensModel.toLowerCase().contains(query) ||
          (p.memo ?? '').toLowerCase().contains(query);
    }).toList();
  }

  // Lens filter
  if (filter.lensModel != null) {
    result = result.where((p) => p.lensModel == filter.lensModel).toList();
  }

  // Focal length range filter
  if (filter.focalLengthRange != null) {
    result = result.where((p) {
      switch (filter.focalLengthRange) {
        case '16-35mm':
          return p.focalLength >= 16 && p.focalLength <= 35;
        case '36-70mm':
          return p.focalLength >= 36 && p.focalLength <= 70;
        case '71-135mm':
          return p.focalLength >= 71 && p.focalLength <= 135;
        case '136mm+':
          return p.focalLength >= 136;
        default:
          return true;
      }
    }).toList();
  }

  // Favorites only
  if (filter.favoritesOnly) {
    result = result.where((p) => p.isFavorite).toList();
  }

  // Sort
  switch (filter.sortOrder) {
    case SortOrder.newestFirst:
      result.sort((a, b) => b.shotAt.compareTo(a.shotAt));
    case SortOrder.oldestFirst:
      result.sort((a, b) => a.shotAt.compareTo(b.shotAt));
  }

  return result;
});

// Analytics period filter
enum AnalyticsPeriod { all, thisMonth, threeMonths }

final analyticsPeriodProvider =
    StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.all);

final analyticsPhotosProvider = Provider<List<PhotoData>>((ref) {
  final photos = ref.watch(photoListProvider);
  final period = ref.watch(analyticsPeriodProvider);

  final now = DateTime(2026, 3, 6);

  switch (period) {
    case AnalyticsPeriod.all:
      return photos;
    case AnalyticsPeriod.thisMonth:
      return photos
          .where(
              (p) => p.shotAt.year == now.year && p.shotAt.month == now.month)
          .toList();
    case AnalyticsPeriod.threeMonths:
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      return photos.where((p) => p.shotAt.isAfter(threeMonthsAgo)).toList();
  }
});
