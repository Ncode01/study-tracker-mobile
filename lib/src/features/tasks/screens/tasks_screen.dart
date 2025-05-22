import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/features/tasks/widgets/task_list_item.dart';

/// Placeholder screen for Tasks.
class TasksScreen extends StatefulWidget {
  /// Creates a [TasksScreen] widget.
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Open'), Tab(text: 'Completed')],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(provider.openTasks),
              _buildTaskList(provider.completedTasks),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskListItem(task: tasks[index]),
    );
  }
}
