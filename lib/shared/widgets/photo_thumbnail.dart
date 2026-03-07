import 'dart:io';

import 'package:flutter/material.dart';

class PhotoThumbnail extends StatelessWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double focalLength;

  const PhotoThumbnail({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.focalLength,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final isRealFile =
        !filePath.startsWith('assets/') && file.existsSync();

    if (isRealFile) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: _colorFromFocalLength(focalLength),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera, color: Colors.white24, size: 28),
            const SizedBox(height: 4),
            Text(
              '${focalLength.toInt()}mm',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFromFocalLength(double fl) {
    if (fl <= 35) return const Color(0xFF1A3A5C);
    if (fl <= 70) return const Color(0xFF2A1A4C);
    if (fl <= 135) return const Color(0xFF1A4C3A);
    return const Color(0xFF4C3A1A);
  }
}
