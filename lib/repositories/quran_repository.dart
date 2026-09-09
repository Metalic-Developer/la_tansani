import '../database/database_service.dart';
import '../models/ayah.dart';

class QuranRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Ayah>> getAyatRange({
    required int surah,
    required int startAyah,
    required int endAyah,
  }) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'quran',
      where: 'sora = ? AND aya_no >= ? AND aya_no <= ?',
      whereArgs: [surah, startAyah, endAyah],
      orderBy: 'aya_no ASC',
    );
    return result.map(Ayah.fromMap).toList();
  }

  Future<Ayah?> getAyah(int id) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'quran',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Ayah.fromMap(result.first);
  }

  Future<List<Map<String, dynamic>>> getAllSurahs() async {
    final db = await _databaseService.database;
    return db.rawQuery('''
      SELECT DISTINCT sora, sora_name
      FROM quran
      ORDER BY sora ASC
    ''');
  }

  Future<List<Ayah>> getAyatOfSora(int surah) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'quran',
      where: 'sora = ?',
      whereArgs: [surah],
      orderBy: 'aya_no ASC',
    );
    return result.map(Ayah.fromMap).toList();
  }
}
