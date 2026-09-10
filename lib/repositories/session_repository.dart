import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';

class SessionRepository {
  final _dbs = DatabaseService.instance;

  Future<int> createSession({
    required String assignmentId,
    required String studentId,
    int? currentAyahId,
  }) async {
    final db = await _dbs.database;
    return db.insert('quran_sessions', {
      'assignment_id': assignmentId,
      'student_id': studentId,
      'started_at': DateTime.now().toIso8601String(),
      'current_ayah_id': currentAyahId,
      'last_ayah_id': currentAyahId,
      'last_confirmed_ayah_id': null,
      'mistakes_count': 0,
      'completed': 0,
    });
  }

  Future<void> updateCurrentAyah({
    required int sessionId,
    required int ayahId,
  }) async {
    final db = await _dbs.database;
    await db.update(
      'quran_sessions',
      {'current_ayah_id': ayahId, 'last_ayah_id': ayahId},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> confirmAyah({
    required int sessionId,
    required int ayahId,
  }) async {
    final db = await _dbs.database;
    await db.update(
      'quran_sessions',
      {
        'current_ayah_id': ayahId,
        'last_ayah_id': ayahId,
        'last_confirmed_ayah_id': ayahId,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> addMistakeToSession({
    required int sessionId,
    required int ayahId,
    String? mistakeType,
    String? note,
  }) async {
    final db = await _dbs.database;
    await db.transaction((txn) async {
      await txn.insert('session_mistakes', {
        'session_id': sessionId,
        'ayah_id': ayahId,
        'mistake_type': mistakeType,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });
      await txn.rawUpdate(
        'UPDATE quran_sessions SET mistakes_count = mistakes_count + 1 WHERE id = ?',
        [sessionId],
      );
    });
  }

  Future<int> getSessionMistakesCount(int sessionId) async {
    final db = await _dbs.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM session_mistakes WHERE session_id = ?',
      [sessionId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<void> endSession({
    required int sessionId,
    required int lastAyahId,
    required int mistakesCount,
  }) async {
    final db = await _dbs.database;
    await db.update(
      'quran_sessions',
      {
        'ended_at': DateTime.now().toIso8601String(),
        'current_ayah_id': lastAyahId,
        'last_ayah_id': lastAyahId,
        'last_confirmed_ayah_id': lastAyahId,
        'mistakes_count': mistakesCount,
        'completed': 1,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}