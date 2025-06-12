import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/models/project_model.dart';

/// Screen for adding a new project
class AddProjectScreen extends StatefulWidget {
  /// Creates an [AddProjectScreen] widget.
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = 'blue';
  String _selectedIcon = 'folder';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'blue', 'color': Colors.blue, 'label': 'Blue'},
    {'name': 'green', 'color': Colors.green, 'label': 'Green'},
    {'name': 'orange', 'color': Colors.orange, 'label': 'Orange'},
    {'name': 'purple', 'color': Colors.purple, 'label': 'Purple'},
    {'name': 'red', 'color': Colors.red, 'label': 'Red'},
    {'name': 'teal', 'color': Colors.teal, 'label': 'Teal'},
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'folder', 'icon': Icons.folder, 'label': 'Folder'},
    {'name': 'book', 'icon': Icons.book, 'label': 'Book'},
    {'name': 'science', 'icon': Icons.science, 'label': 'Science'},
    {'name': 'computer', 'icon': Icons.computer, 'label': 'Computer'},
    {'name': 'language', 'icon': Icons.language, 'label': 'Language'},
    {'name': 'calculate', 'icon': Icons.calculate, 'label': 'Math'},
    {'name': 'brush', 'icon': Icons.brush, 'label': 'Art'},
    {'name': 'music_note', 'icon': Icons.music_note, 'label': 'Music'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final newProject = Project(
        id: UniqueKey().toString(),
        name: _nameController.text.trim(),
        color:
            _colorOptions.firstWhere(
                  (c) => c['name'] == _selectedColor,
                )['color']
                as Color,
        goalMinutes: 360, // Example: 6h goal, can be made user-editable
        loggedMinutes: 0,
        dueDate: null, // Add due date picker if needed
      );
      await projectProvider.addProject(newProject);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProject,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project name is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Project Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter project description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Color Selection
              Text(
                'Project Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children:
                    _colorOptions.map((colorOption) {
                      final isSelected = _selectedColor == colorOption['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = colorOption['name'];
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorOption['color'],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon Selection
              Text(
                'Project Icon',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _iconOptions.map((iconOption) {
                      final isSelected = _selectedIcon == iconOption['name'];
                      final selectedColor =
                          _colorOptions.firstWhere(
                                (color) => color['name'] == _selectedColor,
                              )['color']
                              as Color;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconOption['name'];
                          });
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer
                                    : Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? selectedColor
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            iconOption['icon'],
                            color: isSelected ? selectedColor : Colors.grey,
                            size: 28,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),

              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                _colorOptions.firstWhere(
                                  (color) => color['name'] == _selectedColor,
                                )['color'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _iconOptions.firstWhere(
                              (icon) => icon['name'] == _selectedIcon,
                            )['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isEmpty
                                    ? 'Project Name'
                                    : _nameController.text,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (_descriptionController.text.isNotEmpty)
                                Text(
                                  _descriptionController.text,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
