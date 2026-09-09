import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';

class MistakeRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<void> addRecitationMistake(int ayahId) async {
    final db = await _databaseService.database;
    await db.insert(
      'mistakes',
      {'ayah_id': ayahId, 'recitation_count': 0, 'exam_count': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.rawUpdate(
      'UPDATE mistakes SET recitation_count = recitation_count + 1 WHERE ayah_id = ?',
      [ayahId],
    );
  }

  Future<int> getMistakeCount(int ayahId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'mistakes',
      columns: ['recitation_count', 'exam_count'],
      where: 'ayah_id = ?',
      whereArgs: [ayahId],
      limit: 1,
    );
    if (result.isEmpty) return 0;
    return (result.first['recitation_count'] as int) + (result.first['exam_count'] as int);
  }

  Future<bool> hasMistake(int ayahId) async {
    final count = await getMistakeCount(ayahId);
    return count > 0;
  }
}
