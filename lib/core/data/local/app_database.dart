import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase();

  static const String _databaseName = 'timeflow.db';
  static const int _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (Database db) async {
        await _createSessionIndexes(db);
        await _seedDefaultsIfNeeded(db);
      },
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        accentColorValue INTEGER NOT NULL,
        section TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clubId TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('todo', 'doing', 'done')),
        title TEXT NOT NULL,
        dueLabel TEXT NOT NULL,
        estimateMinutes INTEGER NOT NULL,
        progress REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId TEXT NOT NULL,
        startedAt TEXT NOT NULL,
        endedAt TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        isProductive INTEGER NOT NULL
      )
    ''');

    await _createSessionIndexes(db);

    await _seedDefaultsIfNeeded(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSessionIndexes(db);
    }
    if (oldVersion < 3) {
      await _migrateTasksStatusConstraint(db);
    }
  }

  Future<void> _migrateTasksStatusConstraint(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE tasks_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clubId TEXT NOT NULL,
          status TEXT NOT NULL CHECK(status IN ('todo', 'doing', 'done')),
          title TEXT NOT NULL,
          dueLabel TEXT NOT NULL,
          estimateMinutes INTEGER NOT NULL,
          progress REAL NOT NULL
        )
      ''');

      await txn.execute('''
        INSERT INTO tasks_new(
          id,
          clubId,
          status,
          title,
          dueLabel,
          estimateMinutes,
          progress
        )
        SELECT
          id,
          clubId,
          CASE
            WHEN status IN ('todo', 'doing', 'done') THEN status
            ELSE 'todo'
          END,
          title,
          dueLabel,
          estimateMinutes,
          progress
        FROM tasks
      ''');

      await txn.execute('DROP TABLE tasks');
      await txn.execute('ALTER TABLE tasks_new RENAME TO tasks');
    });
  }

  Future<void> _createSessionIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_ended_at ON sessions (endedAt);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_category_id ON sessions (categoryId);',
    );
  }

  Future<void> _seedDefaultsIfNeeded(Database db) async {
    final categoryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    final taskCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tasks'),
    );

    if ((categoryCount ?? 0) == 0) {
      await db.insert('categories', <String, Object?>{
        'id': 'physics',
        'title': 'Physics',
        'iconCodePoint': Icons.bolt_outlined.codePoint,
        'iconFontFamily': Icons.bolt_outlined.fontFamily,
        'accentColorValue': const Color(0xFF3B82F6).toARGB32(),
        'section': 'A/LEVELS',
        'isDefault': 1,
      });
      await db.insert('categories', <String, Object?>{
        'id': 'maths',
        'title': 'Maths',
        'iconCodePoint': Icons.calculate_outlined.codePoint,
        'iconFontFamily': Icons.calculate_outlined.fontFamily,
        'accentColorValue': const Color(0xFFF43F5E).toARGB32(),
        'section': 'A/LEVELS',
        'isDefault': 1,
      });
      await db.insert('categories', <String, Object?>{
        'id': 'chemistry',
        'title': 'Chemistry',
        'iconCodePoint': Icons.science_outlined.codePoint,
        'iconFontFamily': Icons.science_outlined.fontFamily,
        'accentColorValue': const Color(0xFF22C55E).toARGB32(),
        'section': 'A/LEVELS',
        'isDefault': 1,
      });
      await db.insert('categories', <String, Object?>{
        'id': 'break',
        'title': 'Break',
        'iconCodePoint': Icons.free_breakfast_outlined.codePoint,
        'iconFontFamily': Icons.free_breakfast_outlined.fontFamily,
        'accentColorValue': const Color(0xFF8554F8).toARGB32(),
        'section': 'LIFESTYLE & OTHER',
        'isDefault': 1,
      });
      await db.insert('categories', <String, Object?>{
        'id': 'idle',
        'title': 'Idle',
        'iconCodePoint': Icons.hourglass_empty_rounded.codePoint,
        'iconFontFamily': Icons.hourglass_empty_rounded.fontFamily,
        'accentColorValue': const Color(0xFF64748B).toARGB32(),
        'section': 'LIFESTYLE & OTHER',
        'isDefault': 1,
      });
    }

    if ((taskCount ?? 0) == 0) {
      final defaultTasks = <Map<String, Object?>>[
        <String, Object?>{
          'clubId': 'robotics',
          'status': 'doing',
          'title': 'Test motor mount alignment',
          'dueLabel': 'Due Fri',
          'estimateMinutes': 45,
          'progress': 0.63,
        },
        <String, Object?>{
          'clubId': 'robotics',
          'status': 'todo',
          'title': 'Label prototype wiring',
          'dueLabel': 'Due Sat',
          'estimateMinutes': 20,
          'progress': 0.20,
        },
        <String, Object?>{
          'clubId': 'robotics',
          'status': 'done',
          'title': 'Assemble component kit',
          'dueLabel': 'Completed',
          'estimateMinutes': 30,
          'progress': 1.0,
        },
        <String, Object?>{
          'clubId': 'debate',
          'status': 'doing',
          'title': 'Build rebuttal deck',
          'dueLabel': 'Due Thu',
          'estimateMinutes': 35,
          'progress': 0.48,
        },
        <String, Object?>{
          'clubId': 'hackathon',
          'status': 'todo',
          'title': 'Polish demo copy',
          'dueLabel': 'Due Mon',
          'estimateMinutes': 15,
          'progress': 0.15,
        },
      ];

      final batch = db.batch();
      for (final task in defaultTasks) {
        batch.insert('tasks', task);
      }
      await batch.commit(noResult: true);
    }
  }

  Future<void> wipeAllData() async {
    final Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('sessions');
      await txn.delete('tasks');
      await txn.delete('categories');
    });

    await _seedDefaultsIfNeeded(db);
  }
}
