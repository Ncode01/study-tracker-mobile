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
        activeColor: Theme.of(context).colorScheme.secondary,
        checkColor: Theme.of(context).colorScheme.onPrimary,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      subtitle: Text(
        'Due: 	${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
    );
  }
}
