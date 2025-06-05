import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/models/task_model.dart';
import 'package:study/src/models/session_model.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

/// Singleton class to manage SQLite database operations.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'projects.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        goalMinutes INTEGER NOT NULL,
        loggedMinutes INTEGER DEFAULT 0,
        dueDate TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        projectName TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE study_plan_entries (
        id TEXT PRIMARY KEY,
        subjectName TEXT NOT NULL,
        projectId TEXT,
        date TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        isAllDay INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        reminderDateTime TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for frequently queried columns
    await db.execute('''
      CREATE INDEX idx_study_plan_entries_date ON study_plan_entries(date)
    ''');
    await db.execute('''
      CREATE INDEX idx_study_plan_entries_project_id ON study_plan_entries(projectId)
    ''');
    await db.execute('''
      CREATE INDEX idx_study_plan_entries_completed ON study_plan_entries(isCompleted)
    ''');
  }

  Future<void> insertProject(Project project) async {
    final db = await instance.database;
    await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Project>> getAllProjects() async {
    final db = await instance.database;
    final maps = await db.query('projects');
    return maps.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> updateProject(Project project) async {
    final db = await instance.database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> insertSession(Session session) async {
    final db = await instance.database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Session>> getAllSessions() async {
    final db = await instance.database;
    final maps = await db.query('sessions');
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<List<Session>> getSessionsForDate(DateTime date) async {
    final db = await instance.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final maps = await db.query(
      'sessions',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  // StudyPlanEntry CRUD operations

  /// Inserts a new study plan entry into the database.
  Future<void> insertStudyPlanEntry(StudyPlanEntry entry) async {
    final db = await instance.database;
    await db.insert(
      'study_plan_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing study plan entry in the database.
  Future<void> updateStudyPlanEntry(StudyPlanEntry entry) async {
    final db = await instance.database;
    await db.update(
      'study_plan_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Deletes a study plan entry from the database.
  Future<void> deleteStudyPlanEntry(String id) async {
    final db = await instance.database;
    await db.delete('study_plan_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Retrieves all study plan entries from the database.
  Future<List<StudyPlanEntry>> getAllStudyPlanEntries() async {
    final db = await instance.database;
    final maps = await db.query(
      'study_plan_entries',
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves study plan entries for a specific date.
  Future<List<StudyPlanEntry>> getStudyPlanEntriesForDate(DateTime date) async {
    final db = await instance.database;
    final dateString =
        date.toIso8601String().split('T')[0]; // Get YYYY-MM-DD format
    final maps = await db.query(
      'study_plan_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves study plan entries for a date range.
  Future<List<StudyPlanEntry>> getStudyPlanEntriesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final startString = startDate.toIso8601String().split('T')[0];
    final endString = endDate.toIso8601String().split('T')[0];
    final maps = await db.query(
      'study_plan_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startString, endString],
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves study plan entries associated with a specific project.
  Future<List<StudyPlanEntry>> getStudyPlanEntriesForProject(
    String projectId,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'study_plan_entries',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves incomplete study plan entries (not completed).
  Future<List<StudyPlanEntry>> getIncompleteStudyPlanEntries() async {
    final db = await instance.database;
    final maps = await db.query(
      'study_plan_entries',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves completed study plan entries.
  Future<List<StudyPlanEntry>> getCompletedStudyPlanEntries() async {
    final db = await instance.database;
    final maps = await db.query(
      'study_plan_entries',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'date DESC, startTime DESC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Retrieves overdue study plan entries (past due date and not completed).
  Future<List<StudyPlanEntry>> getOverdueStudyPlanEntries() async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'study_plan_entries',
      where:
          'isCompleted = ? AND (endTime < ? OR (endTime IS NULL AND date < ?))',
      whereArgs: [0, now, now.split('T')[0]],
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((map) => StudyPlanEntry.fromMap(map)).toList();
  }

  /// Marks a study plan entry as completed.
  Future<void> markStudyPlanEntryCompleted(String id) async {
    final db = await instance.database;
    await db.update(
      'study_plan_entries',
      {'isCompleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks a study plan entry as incomplete.
  Future<void> markStudyPlanEntryIncomplete(String id) async {
    final db = await instance.database;
    await db.update(
      'study_plan_entries',
      {'isCompleted': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves a single study plan entry by ID.
  Future<StudyPlanEntry?> getStudyPlanEntryById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'study_plan_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return StudyPlanEntry.fromMap(maps.first);
  }
}
