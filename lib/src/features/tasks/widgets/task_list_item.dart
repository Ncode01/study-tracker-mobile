import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  const TaskListItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) {
          Provider.of<TaskProvider>(
            context,
            listen: false,
          ).toggleTaskCompleted(task);
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        'Due: 	${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
      ),
    );
  }
}
