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
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'quran.db');

    final exists = await File(dbPath).exists();
    if (!exists) {
      final data = await rootBundle.load('assets/db/quran.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(
      dbPath,
      version: 1,
      onOpen: (db) async {
        await _createAppTables(db);
      },
    );

    return db;
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
        last_ayah_id INTEGER,
        mistakes_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_mistakes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        ayah_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(session_id, ayah_id)
      )
    ''');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
