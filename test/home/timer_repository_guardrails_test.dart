import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_tracker_mobile/core/data/local/app_database.dart';
import 'package:study_tracker_mobile/features/home/domain/models/timer_snapshot.dart';
import 'package:study_tracker_mobile/features/home/domain/repositories/timer_repository.dart';

void main() {
  sqfliteFfiInit();

  group('TimerRepository guardrails', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
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
    });

    tearDown(() async {
      await db.close();
    });

    test('restart continuity restores running Pomodoro elapsed', () async {
      final DateTime anchor = DateTime.now().subtract(
        const Duration(hours: 2, minutes: 15),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        'pomodoro_phase': 'focus',
        'pomodoro_phase_duration_seconds': 6 * 60 * 60,
        'pomodoro_elapsed_seconds': 0,
        'pomodoro_is_running': true,
        'pomodoro_running_since_ms': anchor.millisecondsSinceEpoch,
        'pomodoro_completed_focus_sessions': 2,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final TimerRepository repository = TimerRepository(
        database: _FixedAppDatabase(db),
        preferences: prefs,
      );

      final TimerSnapshot snapshot = await repository.loadTimerSnapshot(
        focusMinutes: 60,
      );

      expect(snapshot.phase, PomodoroPhase.focus);
      expect(snapshot.isRunning, isTrue);
      expect(snapshot.completedFocusSessions, 2);

      final int driftSeconds =
          (snapshot.elapsed.inSeconds -
                  DateTime.now().difference(anchor).inSeconds)
              .abs();
      expect(driftSeconds <= 2, isTrue);
    });

    test('saveSession ignores negative durations', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final TimerRepository repository = TimerRepository(
        database: _FixedAppDatabase(db),
        preferences: prefs,
      );

      final DateTime start = DateTime(2026, 4, 5, 10, 0);
      final DateTime end = DateTime(2026, 4, 5, 9, 0);

      await repository.saveSession(
        categoryId: 'physics',
        startedAt: start,
        endedAt: end,
        duration: const Duration(minutes: -30),
        isProductive: true,
      );

      final int rowCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM sessions'),
          ) ??
          0;
      expect(rowCount, 0);
    });

    test('saveSession normalizes endedAt when duration is positive', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final TimerRepository repository = TimerRepository(
        database: _FixedAppDatabase(db),
        preferences: prefs,
      );

      final DateTime start = DateTime(2026, 4, 5, 10, 0);
      final DateTime invalidEnd = DateTime(2026, 4, 5, 9, 59);

      await repository.saveSession(
        categoryId: 'physics',
        startedAt: start,
        endedAt: invalidEnd,
        duration: const Duration(minutes: 5),
        isProductive: true,
      );

      final List<Map<String, Object?>> rows = await db.query('sessions');
      expect(rows.length, 1);
      expect(rows.first['durationSeconds'], 300);

      final DateTime normalizedEnd = DateTime.parse(
        rows.first['endedAt'] as String,
      );
      expect(normalizedEnd, start.add(const Duration(minutes: 5)));
    });
  });
}

class _FixedAppDatabase extends AppDatabase {
  _FixedAppDatabase(this._db);

  final Database _db;

  @override
  Future<Database> get database async => _db;
}
