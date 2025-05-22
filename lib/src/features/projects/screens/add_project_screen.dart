import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/models/project_model.dart';

/// Form screen for creating a new project.
class AddProjectScreen extends StatefulWidget {
  /// Creates an [AddProjectScreen].
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalTimeController = TextEditingController();
  Color _selectedColor = AppColors.primaryColor;
  DateTime? _selectedDueDate;

  final List<Color> _colorOptions = [
    AppColors.primaryColor,
    Colors.green,
    Colors.redAccent,
    Colors.orange,
    Colors.purple,
    Colors.blueAccent,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _goalTimeController.dispose();
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
      appBar: AppBar(title: const Text('New Project')),
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
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: AppColors.textColor),
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter a project name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _goalTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Time (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: AppColors.textColor),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a goal time in minutes';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Enter a valid number of minutes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Color',
                    style: TextStyle(color: AppColors.secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children:
                        _colorOptions.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        )
                                        : null,
                              ),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: isSelected ? 20 : 16,
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
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
                          final uuid = const Uuid().v4();
                          final name = _nameController.text.trim();
                          final goalMinutes =
                              int.tryParse(_goalTimeController.text.trim()) ??
                              0;
                          final project = Project(
                            id: uuid,
                            name: name,
                            color: _selectedColor,
                            goalMinutes: goalMinutes,
                            loggedMinutes: 0,
                            dueDate: _selectedDueDate,
                          );
                          final provider = Provider.of<ProjectProvider>(
                            context,
                            listen: false,
                          );
                          await provider.addProject(project);
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create Project'),
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
