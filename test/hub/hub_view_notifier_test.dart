import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_tracker_mobile/core/data/local/app_database.dart';
import 'package:study_tracker_mobile/core/providers/core_providers.dart';
import 'package:study_tracker_mobile/features/hub/application/hub_view_notifier.dart';
import 'package:study_tracker_mobile/features/hub/presentation/providers/hub_providers.dart';

void main() {
  sqfliteFfiInit();

  test(
    'hub notifier always exposes maths, physics, chemistry subjects',
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

      for (final row in <Map<String, Object?>>[
        {
          'id': 'maths',
          'title': 'Maths',
          'iconCodePoint': 0xe2aa,
          'iconFontFamily': 'MaterialIcons',
          'accentColorValue': 0xFFF43F5E,
          'section': 'A/LEVELS',
          'isDefault': 1,
        },
        {
          'id': 'physics',
          'title': 'Physics',
          'iconCodePoint': 0xe3f4,
          'iconFontFamily': 'MaterialIcons',
          'accentColorValue': 0xFF3B82F6,
          'section': 'A/LEVELS',
          'isDefault': 1,
        },
        {
          'id': 'chemistry',
          'title': 'Chemistry',
          'iconCodePoint': 0xe3d2,
          'iconFontFamily': 'MaterialIcons',
          'accentColorValue': 0xFF22C55E,
          'section': 'A/LEVELS',
          'isDefault': 1,
        },
      ]) {
        await db.insert('categories', row);
      }

      final DateTime now = DateTime.now();
      await db.insert('hub_classes', <String, Object?>{
        'subjectId': 'physics',
        'teacherName': 'Ms. Wren',
        'weekday': 2,
        'startMinutes': 9 * 60,
        'durationMinutes': 90,
        'attendanceStatus': 'pending',
        'recordingPlannedAt': null,
        'recordingDurationMinutes': null,
        'recordingCompleted': 0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          databaseProvider.overrideWithValue(_FixedAppDatabase(db)),
        ],
      );
      addTearDown(container.dispose);

      final HubViewState state = await container.read(hubViewProvider.future);

      expect(state.subjects.length, 3);
      expect(
        state.subjects.map((HubSubject s) => s.id).toList(growable: false),
        <String>['maths', 'physics', 'chemistry'],
      );
      expect(
        state.subjects
            .firstWhere((HubSubject s) => s.id == 'physics')
            .classes
            .length,
        1,
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
