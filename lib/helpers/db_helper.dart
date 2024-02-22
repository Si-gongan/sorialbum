import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/image.dart';
import 'utils.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path_ = await getDatabasesPath();
    return await openDatabase(
      path.join(path_, 'galleryApp.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, assetPath TEXT, caption TEXT, description TEXT, userMemo TEXT, generalTags TEXT, alertTags TEXT, vector TEXT, createdAt TEXT)',
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
    await db.update('images', image.toMap(), where: 'id = ?', whereArgs: [image.id]);
  }

  Future<void> deleteImage(int id) async {
    final db = await database;
    await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocalImage>> getAllImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images');
    return List.generate(maps.length, (i) {
      return LocalImage.fromMap(maps[i]);
    });
  }

  Future<List<LocalImage>> searchImages(String keyword) async {
    final db = await database;
    // 여기서는 간단히 키워드가 포함된 이미지를 찾는 예제 쿼리를 제공합니다.
    // 실제 구현에서는 워드 임베딩 벡터 값을 고려하여 유사도를 계산하는 로직이 필요합니다.
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'generalTags LIKE ? OR alertTags LIKE ? OR caption LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
    );

    return List.generate(maps.length, (i) {
      return LocalImage.fromMap(maps[i]);
    });
  }

  Future<List<LocalImage>> queryImagesBySimilarity(String query) async {
  final queryVec = [.0]; // await text2vec(query); // 텍스트 쿼리를 벡터로 변환
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('images');
  List<LocalImage> images = List.generate(maps.length, (i) {
    return LocalImage.fromMap(maps[i]);
  });

  // 각 이미지의 vector와 쿼리 벡터 간 코사인 유사도 계산
  final similarityScores = images.map((image) {
    final imageVec = image.vector?.map((e) => e.toDouble()).toList() ?? [];
    return {
      'image': image,
      'similarity': cosineSimilarity(queryVec, imageVec),
      };
    }).toList();

    // 유사도에 따라 정렬
    similarityScores.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));

    // 정렬된 이미지 리스트 반환
    return similarityScores.map((e) => e['image'] as LocalImage).toList();
  }
}