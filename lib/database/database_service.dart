import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'quran.db');

    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/db/quran.db');
      await File(dbPath).writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, v) async => _createAppTables(db),
      onUpgrade: (db, oldV, newV) async => _migrate(db, oldV),
      onOpen: (db) async => _createAppTables(db),
    );
  }

  Future<void> _createAppTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mistakes (
        ayah_id INTEGER PRIMARY KEY,
        recitation_count INTEGER NOT NULL DEFAULT 0,
        exam_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quran_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assignment_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        current_ayah_id INTEGER,
        last_ayah_id INTEGER,
        last_confirmed_ayah_id INTEGER,
        mistakes_count INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_mistakes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        ayah_id INTEGER NOT NULL,
        mistake_type TEXT,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_session_mistakes_session
      ON session_mistakes(session_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_session_mistakes_ayah
      ON session_mistakes(ayah_id)
    ''');
  }

  Future<void> _migrate(Database db, int oldVersion) async {
    if (oldVersion < 2) {
      await _safeAdd(db, 'quran_sessions', 'current_ayah_id INTEGER');
      await _safeAdd(db, 'quran_sessions', 'last_confirmed_ayah_id INTEGER');
      await _safeAdd(db, 'quran_sessions', 'completed INTEGER NOT NULL DEFAULT 0');
      await _safeAdd(db, 'session_mistakes', 'mistake_type TEXT');
      await _safeAdd(db, 'session_mistakes', 'note TEXT');
    }
    await _createAppTables(db);
  }

  Future<void> _safeAdd(Database db, String table, String def) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $def');
    } catch (_) {}
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}