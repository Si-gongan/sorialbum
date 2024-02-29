import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path_ = await getDatabasesPath();
    if (kIsWeb) {
      // 웹용 데이터베이스 초기화
      databaseFactory = databaseFactoryFfiWeb;
    }
    return await openDatabase(
      path.join(path_, 'galleryApp.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, assetPath TEXT, thumbAssetPath TEXT, imageUrl TEXT, caption TEXT, description TEXT, ocr TEXT, userMemo TEXT, generalTags TEXT, alertTags TEXT, vector TEXT, storedAt TEXT, createdAt TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertImage(LocalImage image) async {
    final db = await database;
    await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertImages(List<LocalImage> images) async {
    final db = await database;
    await db.transaction((txn) async {
      for (LocalImage image in images) {
        await txn.insert(
          'images',
          image.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<LocalImage?> getImageById(int id) async {
    final db = await database;
    final maps = await db.query('images', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return LocalImage.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateImage(LocalImage image) async {
    final db = await database;
    await db.update('images', image.toMap(),
        where: 'assetPath = ?', whereArgs: [image.assetPath]);
  }

  Future<void> updateImageByMap(Map<String, dynamic> map) async {
    final db = await database;
    await db.update('images', map,
        where: 'assetPath = ?', whereArgs: [map['assetPath']]);
  }

  Future<void> updateImagesByMaps(List<Map<String, dynamic>> maps) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var map in maps) {
        await txn.update(
          'images',
          map,
          where: 'assetPath = ?',
          whereArgs: [map['assetPath']],
        );
      }
    });
  }

  Future<void> deleteImage(LocalImage image) async {
    final db = await database;
    await db
        .delete('images', where: 'assetPath = ?', whereArgs: [image.assetPath]);
  }

  Future<List<LocalImage>> getAllImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('images', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return LocalImage.fromMap(maps[i]);
    });
  }

  Future<List<LocalImage>> searchImagesByKeyword(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images',
        where:
            'generalTags LIKE ? OR caption LIKE ? OR description LIKE ? OR ocr LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%'],
        orderBy: 'createdAt DESC');
    return maps.map((map) => LocalImage.fromMap(map)).toList();
  }
}
