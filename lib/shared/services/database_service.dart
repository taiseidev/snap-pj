import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/photo_data.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shotlog.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE photos (
            id TEXT PRIMARY KEY,
            filePath TEXT NOT NULL,
            shotAt TEXT NOT NULL,
            cameraModel TEXT NOT NULL,
            lensModel TEXT NOT NULL,
            focalLength REAL NOT NULL,
            aperture REAL NOT NULL,
            shutterSpeed TEXT NOT NULL,
            iso INTEGER NOT NULL,
            rating INTEGER NOT NULL DEFAULT 0,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            memo TEXT
          )
        ''');
      },
    );
  }

  static Future<List<PhotoData>> getAllPhotos() async {
    final db = await database;
    final maps = await db.query('photos', orderBy: 'shotAt DESC');
    return maps.map(_fromMap).toList();
  }

  static Future<void> insertPhoto(PhotoData photo) async {
    final db = await database;
    await db.insert('photos', _toMap(photo),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertPhotos(List<PhotoData> photos) async {
    final db = await database;
    final batch = db.batch();
    for (final photo in photos) {
      batch.insert('photos', _toMap(photo),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> updatePhoto(PhotoData photo) async {
    final db = await database;
    await db.update('photos', _toMap(photo),
        where: 'id = ?', whereArgs: [photo.id]);
  }

  static Future<void> deletePhoto(String id) async {
    final db = await database;
    await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM photos');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Map<String, dynamic> _toMap(PhotoData photo) {
    return {
      'id': photo.id,
      'filePath': photo.filePath,
      'shotAt': photo.shotAt.toIso8601String(),
      'cameraModel': photo.cameraModel,
      'lensModel': photo.lensModel,
      'focalLength': photo.focalLength,
      'aperture': photo.aperture,
      'shutterSpeed': photo.shutterSpeed,
      'iso': photo.iso,
      'rating': photo.rating,
      'isFavorite': photo.isFavorite ? 1 : 0,
      'memo': photo.memo,
    };
  }

  static PhotoData _fromMap(Map<String, dynamic> map) {
    return PhotoData(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      shotAt: DateTime.parse(map['shotAt'] as String),
      cameraModel: map['cameraModel'] as String,
      lensModel: map['lensModel'] as String,
      focalLength: (map['focalLength'] as num).toDouble(),
      aperture: (map['aperture'] as num).toDouble(),
      shutterSpeed: map['shutterSpeed'] as String,
      iso: map['iso'] as int,
      rating: map['rating'] as int,
      isFavorite: (map['isFavorite'] as int) == 1,
      memo: map['memo'] as String?,
    );
  }
}
