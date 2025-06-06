import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/models/task_model.dart';
import 'package:study/src/providers/project_provider.dart';

/// Form screen for creating a new task.
class AddTaskScreen extends StatefulWidget {
  /// Creates an [AddTaskScreen].
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProject;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.primaryColor,
                surface: AppColors.cardColor,
                onSurface: AppColors.textColor,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: AppColors.textColor),
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter a task name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: AppColors.textColor),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProject,
                    items:
                        context
                            .read<ProjectProvider>()
                            .projects
                            .map(
                              (proj) => DropdownMenuItem<String>(
                                value: proj.id,
                                child: Text(proj.name),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => _selectedProject = value),
                    decoration: const InputDecoration(
                      labelText: 'Assign to Project',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: AppColors.textColor),
                    dropdownColor: AppColors.cardColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Due Date',
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDueDate != null
                              ? '${_selectedDueDate!.year}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}'
                              : 'Not set',
                          style: const TextStyle(color: AppColors.textColor),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDueDate,
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_selectedProject == null ||
                              _selectedDueDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a project and due date.',
                                ),
                              ),
                            );
                            return;
                          }
                          final task = Task(
                            id: const Uuid().v4(),
                            projectId: _selectedProject!,
                            title: _nameController.text.trim(),
                            description: _descriptionController.text.trim(),
                            dueDate: _selectedDueDate!,
                          );
                          await Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          ).addTask(task);
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Create Task'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
