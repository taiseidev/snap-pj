class PhotoData {
  final String id;
  final String filePath;
  final DateTime shotAt;
  final String cameraModel;
  final String lensModel;
  final double focalLength;
  final double aperture;
  final String shutterSpeed;
  final int iso;
  final int rating;
  final bool isFavorite;
  final String? memo;

  const PhotoData({
    required this.id,
    required this.filePath,
    required this.shotAt,
    required this.cameraModel,
    required this.lensModel,
    required this.focalLength,
    required this.aperture,
    required this.shutterSpeed,
    required this.iso,
    this.rating = 0,
    this.isFavorite = false,
    this.memo,
  });

  PhotoData copyWith({
    int? rating,
    bool? isFavorite,
    String? memo,
  }) {
    return PhotoData(
      id: id,
      filePath: filePath,
      shotAt: shotAt,
      cameraModel: cameraModel,
      lensModel: lensModel,
      focalLength: focalLength,
      aperture: aperture,
      shutterSpeed: shutterSpeed,
      iso: iso,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      memo: memo ?? this.memo,
    );
  }
}
