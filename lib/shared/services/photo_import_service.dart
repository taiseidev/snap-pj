import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/photo_data.dart';

class PhotoImportService {
  static final _picker = ImagePicker();
  static const _uuid = Uuid();

  static Future<List<PhotoData>> pickAndImportPhotos() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return [];

    final photos = <PhotoData>[];
    for (final xFile in pickedFiles) {
      final photo = await _processImage(xFile);
      if (photo != null) photos.add(photo);
    }
    return photos;
  }

  static Future<PhotoData?> _processImage(XFile xFile) async {
    try {
      // Copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(appDir.path, 'photos'));
      if (!photosDir.existsSync()) {
        photosDir.createSync(recursive: true);
      }

      final fileName = '${_uuid.v4()}${p.extension(xFile.name)}';
      final savedPath = p.join(photosDir.path, fileName);
      final bytes = await xFile.readAsBytes();
      await File(savedPath).writeAsBytes(bytes);

      // Read EXIF data
      final exifData = await _readExif(bytes);

      return PhotoData(
        id: _uuid.v4(),
        filePath: savedPath,
        shotAt: exifData.shotAt ?? DateTime.now(),
        cameraModel: exifData.cameraModel ?? '不明',
        lensModel: exifData.lensModel ?? '不明',
        focalLength: exifData.focalLength ?? 50.0,
        aperture: exifData.aperture ?? 2.8,
        shutterSpeed: exifData.shutterSpeed ?? '1/125',
        iso: exifData.iso ?? 400,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<_ExifResult> _readExif(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return _ExifResult();

      return _ExifResult(
        cameraModel: _getString(tags, 'Image Model'),
        lensModel: _getString(tags, 'EXIF LensModel'),
        focalLength: _getDouble(tags, 'EXIF FocalLength'),
        aperture: _getDouble(tags, 'EXIF FNumber'),
        shutterSpeed: _getString(tags, 'EXIF ExposureTime'),
        iso: _getInt(tags, 'EXIF ISOSpeedRatings'),
        shotAt: _getDateTime(tags, 'EXIF DateTimeOriginal'),
      );
    } catch (_) {
      return _ExifResult();
    }
  }

  static String? _getString(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    final value = tag.printable.trim();
    return value.isEmpty ? null : value;
  }

  static double? _getDouble(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    try {
      final value = tag.printable;
      if (value.contains('/')) {
        final parts = value.split('/');
        return double.parse(parts[0]) / double.parse(parts[1]);
      }
      return double.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  static int? _getInt(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    return int.tryParse(tag.printable);
  }

  static DateTime? _getDateTime(Map<String, IfdTag> tags, String key) {
    final tag = tags[key];
    if (tag == null) return null;
    try {
      // EXIF format: "2024:01:15 14:30:00"
      final value = tag.printable.replaceFirst(RegExp(r'^(\d{4}):(\d{2}):'), r'$1-$2-');
      return DateTime.tryParse(value.replaceFirst(':', '-').replaceFirst(':', '-'));
    } catch (_) {
      return null;
    }
  }
}

class _ExifResult {
  final String? cameraModel;
  final String? lensModel;
  final double? focalLength;
  final double? aperture;
  final String? shutterSpeed;
  final int? iso;
  final DateTime? shotAt;

  _ExifResult({
    this.cameraModel,
    this.lensModel,
    this.focalLength,
    this.aperture,
    this.shutterSpeed,
    this.iso,
    this.shotAt,
  });
}
