import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';

class MistakeRepository {
  final _dbs = DatabaseService.instance;

  Future<void> addRecitationMistake(int ayahId) async {
    final db = await _dbs.database;
    await db.transaction((txn) async {
      await txn.insert(
        'mistakes',
        {'ayah_id': ayahId, 'recitation_count': 0, 'exam_count': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.rawUpdate(
        'UPDATE mistakes SET recitation_count = recitation_count + 1 WHERE ayah_id = ?',
        [ayahId],
      );
    });
  }

  Future<void> addExamMistake(int ayahId) async {
    final db = await _dbs.database;
    await db.transaction((txn) async {
      await txn.insert(
        'mistakes',
        {'ayah_id': ayahId, 'recitation_count': 0, 'exam_count': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.rawUpdate(
        'UPDATE mistakes SET exam_count = exam_count + 1 WHERE ayah_id = ?',
        [ayahId],
      );
    });
  }

  Future<int> getMistakeCount(int ayahId) async {
    final db = await _dbs.database;
    final result = await db.query(
      'mistakes',
      columns: ['recitation_count', 'exam_count'],
      where: 'ayah_id = ?',
      whereArgs: [ayahId],
      limit: 1,
    );
    if (result.isEmpty) return 0;
    final row = result.first;
    return (row['recitation_count'] as int) + (row['exam_count'] as int);
  }
}