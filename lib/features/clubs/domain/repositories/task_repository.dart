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

  Future<StudyTask> createTask({
    required String clubId,
    required String projectId,
    required String status,
    required String title,
    required String dueLabel,
    required int estimateMinutes,
    required double progress,
  }) async {
    final db = await _database.database;
    final int id = await db.insert('tasks', <String, Object?>{
      'clubId': clubId,
      'projectId': projectId,
      'status': status,
      'title': title,
      'dueLabel': dueLabel,
      'estimateMinutes': estimateMinutes,
      'progress': progress,
    });

    return StudyTask(
      id: id,
      clubId: clubId,
      projectId: projectId,
      status: status,
      title: title,
      dueLabel: dueLabel,
      estimateMinutes: estimateMinutes,
      progress: progress,
    );
  }

  Future<void> updateTaskStatus({
    required int taskId,
    required String status,
    required double progress,
  }) async {
    final db = await _database.database;
    await db.update(
      'tasks',
      <String, Object?>{'status': status, 'progress': progress},
      where: 'id = ?',
      whereArgs: <Object?>[taskId],
    );
  }

  Future<void> deleteTask({required int taskId}) async {
    final db = await _database.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: <Object?>[taskId]);
  }
}
