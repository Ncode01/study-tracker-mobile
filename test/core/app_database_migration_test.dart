import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_tracker_mobile/core/data/local/app_database.dart';

void main() {
  sqfliteFfiInit();

  group('AppDatabase migration', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

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

      await db.insert('categories', <String, Object?>{
        'id': 'physics',
        'title': 'Physics',
        'iconCodePoint': 0,
        'iconFontFamily': 'MaterialIcons',
        'accentColorValue': 0xFF3B82F6,
        'section': 'A/LEVELS',
        'isDefault': 1,
      });

      await db.insert('sessions', <String, Object?>{
        'categoryId': 'physics',
        'startedAt': DateTime(2026, 4, 5, 9, 0).toIso8601String(),
        'endedAt': DateTime(2026, 4, 5, 10, 0).toIso8601String(),
        'durationSeconds': 3600,
        'isProductive': 1,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'upgrading v4 -> v6 adds planned and hub tables while keeping data',
      () async {
        final AppDatabase appDatabase = AppDatabase();

        await appDatabase.upgradeSchemaForTest(
          db: db,
          oldVersion: 4,
          newVersion: 6,
        );

        final List<Map<String, Object?>> tables = await db.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name = 'planned_items'
      ''');

        expect(tables, isNotEmpty);

        final List<Map<String, Object?>> indexes = await db.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index' AND name IN (
          'idx_planned_items_start_at',
          'idx_planned_items_end_at',
          'idx_planned_items_category_id'
        )
      ''');

        expect(indexes.length, 3);

        final List<Map<String, Object?>> hubTables = await db.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name = 'hub_classes'
      ''');

        expect(hubTables, isNotEmpty);

        final List<Map<String, Object?>> hubIndexes = await db.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index' AND name IN (
          'idx_hub_classes_subject_id',
          'idx_hub_classes_weekday',
          'idx_hub_classes_recording_planned_at'
        )
      ''');

        expect(hubIndexes.length, 3);

        final int categoryCount =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM categories'),
            ) ??
            0;
        final int sessionCount =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM sessions'),
            ) ??
            0;

        expect(categoryCount, 1);
        expect(sessionCount, 1);
      },
    );
  });
}
