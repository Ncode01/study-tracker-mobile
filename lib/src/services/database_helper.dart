import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study/src/models/project_model.dart';
import 'package:study/src/models/task_model.dart';
import 'package:study/src/models/session_model.dart';

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
    final dateString = date.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'
    final maps = await db.query(
      'sessions',
      where: "strftime('%Y-%m-%d', startTime) = ?",
      whereArgs: [dateString],
    );
    return maps.map((map) => Session.fromMap(map)).toList();
  }

  Future<Map<String, int>> getAggregatedTimePerDay(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''SELECT strftime('%Y-%m-%d', startTime) as day, SUM(durationMinutes) as totalMinutes
         FROM sessions
         WHERE startTime BETWEEN ? AND ?
         GROUP BY day''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return {
      for (var row in result)
        row['day'] as String: (row['totalMinutes'] as int? ?? 0),
    };
  }

  Future<Map<String, int>> getAggregatedTimePerProject(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''SELECT projectName, SUM(durationMinutes) as totalMinutes
         FROM sessions
         WHERE startTime BETWEEN ? AND ?
         GROUP BY projectName''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return {
      for (var row in result)
        row['projectName'] as String: (row['totalMinutes'] as int? ?? 0),
    };
  }
}
