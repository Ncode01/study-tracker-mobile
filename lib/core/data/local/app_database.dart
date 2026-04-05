import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase();

  static const String _databaseName = 'timeflow.db';
  static const int _databaseVersion = 4;

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
    if (oldVersion < 4) {
      await _removeLegacySeededTasksIfPresent(db);
    }
  }

  Future<void> _removeLegacySeededTasksIfPresent(Database db) async {
    final List<Map<String, Object?>> rows = await db.query(
      'tasks',
      columns: const <String>[
        'clubId',
        'status',
        'title',
        'dueLabel',
        'estimateMinutes',
      ],
    );

    if (rows.length != _legacyTaskSeedSignatures.length) {
      return;
    }

    final Set<String> signatures =
        rows.map((Map<String, Object?> row) => _taskSignature(row)).toSet();

    if (signatures.length != _legacyTaskSeedSignatures.length) {
      return;
    }

    if (!signatures.containsAll(_legacyTaskSeedSignatures)) {
      return;
    }

    await db.delete('tasks');
  }

  String _taskSignature(Map<String, Object?> row) {
    final String clubId = row['clubId'] as String? ?? '';
    final String status = row['status'] as String? ?? '';
    final String title = row['title'] as String? ?? '';
    final String dueLabel = row['dueLabel'] as String? ?? '';
    final int estimateMinutes = (row['estimateMinutes'] as num?)?.toInt() ?? 0;
    return '$clubId|$status|$title|$dueLabel|$estimateMinutes';
  }

  static const Set<String> _legacyTaskSeedSignatures = <String>{
    'robotics|doing|Test motor mount alignment|Due Fri|45',
    'robotics|todo|Label prototype wiring|Due Sat|20',
    'robotics|done|Assemble component kit|Completed|30',
    'debate|doing|Build rebuttal deck|Due Thu|35',
    'hackathon|todo|Polish demo copy|Due Mon|15',
  };

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
