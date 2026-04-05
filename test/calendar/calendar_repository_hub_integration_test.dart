import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_tracker_mobile/core/data/local/app_database.dart';
import 'package:study_tracker_mobile/features/calendar/domain/models/planned_item.dart';
import 'package:study_tracker_mobile/features/calendar/domain/repositories/calendar_repository.dart';

void main() {
  sqfliteFfiInit();

  test(
    'calendar repository merges hub live class and recording planned items',
    () async {
      final Database db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      addTearDown(() async {
        await db.close();
      });

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
      CREATE TABLE planned_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId TEXT NOT NULL,
        title TEXT NOT NULL,
        startAt TEXT NOT NULL,
        endAt TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE hub_classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId TEXT NOT NULL,
        teacherName TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        startMinutes INTEGER NOT NULL,
        durationMinutes INTEGER NOT NULL,
        attendanceStatus TEXT NOT NULL DEFAULT 'pending',
        recordingPlannedAt TEXT,
        recordingDurationMinutes INTEGER,
        recordingCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

      await db.insert('categories', <String, Object?>{
        'id': 'physics',
        'title': 'Physics',
        'iconCodePoint': 0xe3f4,
        'iconFontFamily': 'MaterialIcons',
        'accentColorValue': 0xFF3B82F6,
        'section': 'A/LEVELS',
        'isDefault': 1,
      });

      final DateTime now = DateTime.now();
      final DateTime recordingAt = DateTime(
        now.year,
        now.month,
        now.day,
        19,
        0,
      );
      await db.insert('hub_classes', <String, Object?>{
        'subjectId': 'physics',
        'teacherName': 'Ms. Carter',
        'weekday': now.weekday,
        'startMinutes': 9 * 60,
        'durationMinutes': 60,
        'attendanceStatus': 'missed',
        'recordingPlannedAt': recordingAt.toIso8601String(),
        'recordingDurationMinutes': 45,
        'recordingCompleted': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final SqliteCalendarRepository repository = SqliteCalendarRepository(
        database: _FixedAppDatabase(db),
        preferences: preferences,
      );

      final List<PlannedItem> plannedItems = await repository.loadPlannedItems(
        selectedDate: DateTime(now.year, now.month, now.day),
      );

      expect(
        plannedItems.any(
          (PlannedItem item) => item.source == PlannedItemSource.hubLiveClass,
        ),
        isTrue,
      );
      expect(
        plannedItems.any(
          (PlannedItem item) => item.source == PlannedItemSource.hubRecording,
        ),
        isTrue,
      );
      expect(
        plannedItems
            .where(
              (PlannedItem item) => item.source != PlannedItemSource.manual,
            )
            .every((PlannedItem item) => item.isEditable == false),
        isTrue,
      );
    },
  );
}

class _FixedAppDatabase extends AppDatabase {
  _FixedAppDatabase(this._db);

  final Database _db;

  @override
  Future<Database> get database async => _db;
}
