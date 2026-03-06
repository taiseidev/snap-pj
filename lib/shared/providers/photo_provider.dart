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
}

final selectedPhotoProvider = StateProvider<PhotoData?>((ref) => null);
