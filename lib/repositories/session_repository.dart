import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';

class SessionRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<int> createSession({
    required String assignmentId,
    required String studentId,
  }) async {
    final db = await _databaseService.database;
    return await db.insert('quran_sessions', {
      'assignment_id': assignmentId,
      'student_id': studentId,
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addMistakeToSession({
    required int sessionId,
    required int ayahId,
  }) async {
    final db = await _databaseService.database;
    await db.insert(
      'session_mistakes',
      {
        'session_id': sessionId,
        'ayah_id': ayahId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> endSession({
    required int sessionId,
    required int lastAyahId,
    required int mistakesCount,
  }) async {
    final db = await _databaseService.database;
    await db.update(
      'quran_sessions',
      {
        'ended_at': DateTime.now().toIso8601String(),
        'last_ayah_id': lastAyahId,
        'mistakes_count': mistakesCount,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
