import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_tracker_mobile/core/data/local/app_database.dart';
import 'package:study_tracker_mobile/core/providers/core_providers.dart';
import 'package:study_tracker_mobile/features/home/domain/models/home_view_state.dart';
import 'package:study_tracker_mobile/features/home/presentation/providers/home_providers.dart';

void main() {
  sqfliteFfiInit();

  test(
    'switchCategory on same category does not write duplicate sessions',
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
        'iconCodePoint': 0xe3f4,
        'iconFontFamily': 'MaterialIcons',
        'accentColorValue': 0xFF3B82F6,
        'section': 'A/LEVELS',
        'isDefault': 1,
      });
      await db.insert('categories', <String, Object?>{
        'id': 'maths',
        'title': 'Maths',
        'iconCodePoint': 0xe2aa,
        'iconFontFamily': 'MaterialIcons',
        'accentColorValue': 0xFFF43F5E,
        'section': 'A/LEVELS',
        'isDefault': 1,
      });

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(_FixedAppDatabase(db)),
        ],
      );
      addTearDown(container.dispose);

      final HomeViewState initialState = await container.read(
        homeViewNotifierProvider.future,
      );

      await container
          .read(homeViewNotifierProvider.notifier)
          .switchCategory(initialState.currentCategory);

      final int sessionCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM sessions'),
          ) ??
          0;

      expect(sessionCount, 0);
    },
  );

  test('switchCategory resets timer elapsed for new category', () async {
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
      'iconCodePoint': 0xe3f4,
      'iconFontFamily': 'MaterialIcons',
      'accentColorValue': 0xFF3B82F6,
      'section': 'A/LEVELS',
      'isDefault': 1,
    });
    await db.insert('categories', <String, Object?>{
      'id': 'maths',
      'title': 'Maths',
      'iconCodePoint': 0xe2aa,
      'iconFontFamily': 'MaterialIcons',
      'accentColorValue': 0xFFF43F5E,
      'section': 'A/LEVELS',
      'isDefault': 1,
    });

    final DateTime oldSessionStart = DateTime.now().subtract(
      const Duration(minutes: 47),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      'selected_category_id': 'physics',
      'timer_session_start_time_ms': oldSessionStart.millisecondsSinceEpoch,
      'timer_elapsed_seconds': 47 * 60,
    });
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        databaseProvider.overrideWithValue(_FixedAppDatabase(db)),
      ],
    );
    addTearDown(container.dispose);

    final HomeViewState initialState = await container.read(
      homeViewNotifierProvider.future,
    );
    final maths = initialState.categories.firstWhere((c) => c.id == 'maths');

    await container
        .read(homeViewNotifierProvider.notifier)
        .switchCategory(maths);

    final HomeViewState nextState =
        container.read(homeViewNotifierProvider).value!;
    expect(nextState.currentCategory.id, 'maths');
    expect(nextState.timer.elapsed.inSeconds <= 1, isTrue);
  });
}

class _FixedAppDatabase extends AppDatabase {
  _FixedAppDatabase(this._db);

  final Database _db;

  @override
  Future<Database> get database async => _db;
}
