import '../../../../core/data/local/app_database.dart';
import '../models/study_task.dart';

class TaskRepository {
  TaskRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  Future<List<StudyTask>> loadTasks() async {
    final db = await _database.database;
    final rows = await db.query('tasks', orderBy: 'id ASC');
    return rows
        .map((Map<String, Object?> row) => StudyTask.fromMap(row))
        .toList(growable: false);
  }
}
