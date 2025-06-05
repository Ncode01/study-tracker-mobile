import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:study/src/constants/app_colors.dart';
import 'package:study/src/features/daily_study_planner/providers/study_plan_provider.dart';
import 'package:study/src/features/projects/providers/project_provider.dart';
import 'package:study/src/models/study_plan_entry_model.dart';

/// Screen for adding or editing a study plan entry.
class AddStudyPlanEntryScreen extends StatefulWidget {
  /// Initial date for the study plan entry.
  final DateTime initialDate;

  /// Study plan entry to edit (null for new entry).
  final StudyPlanEntry? editingEntry;

  /// ID of the study plan entry to edit (for deep linking).
  final String? editingEntryId;

  /// Creates an [AddStudyPlanEntryScreen].
  const AddStudyPlanEntryScreen({
    super.key,
    required this.initialDate,
    this.editingEntry,
    this.editingEntryId,
  });

  @override
  State<AddStudyPlanEntryScreen> createState() =>
      _AddStudyPlanEntryScreenState();
}

class _AddStudyPlanEntryScreenState extends State<AddStudyPlanEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedProjectId;
  DateTime? _reminderDateTime;
  bool _isAllDay = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    // Initialize with default values - will be updated in didChangeDependencies
    _subjectController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = widget.initialDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeFields();
      _isInitialized = true;
    }
  }

  void _initializeFields() {
    // Check for named route arguments first
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final namedInitialDate = args['initialDate'] as DateTime?;
      final namedEditingEntry = args['editingEntry'] as StudyPlanEntry?;

      if (namedEditingEntry != null) {
        // Editing existing entry from named route
        _initializeFromEntry(namedEditingEntry);
        return;
      } else if (namedInitialDate != null) {
        // Creating new entry with date from named route
        _selectedDate = namedInitialDate;
        return;
      }
    }

    // Fall back to constructor parameters (for backward compatibility)
    if (widget.editingEntry != null) {
      // Editing existing entry (direct entry object passed)
      _initializeFromEntry(widget.editingEntry!);
    } else if (widget.editingEntryId != null) {
      // Editing existing entry (ID passed for deep linking)
      _loadEntryById(widget.editingEntryId!);
    }
    // Default case is already handled in initState
  }

  void _initializeFromEntry(StudyPlanEntry entry) {
    _subjectController = TextEditingController(text: entry.subjectName);
    _notesController = TextEditingController(text: entry.notes ?? '');
    _selectedDate = entry.date;
    _startTime = entry.startTime;
    _endTime = entry.endTime;
    _selectedProjectId = entry.projectId;
    _reminderDateTime = entry.reminderDateTime;
    _isAllDay = entry.isAllDay;
  }

  Future<void> _loadEntryById(String entryId) async {
    // Initialize with defaults first
    _subjectController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = widget.initialDate;

    try {
      final provider = context.read<StudyPlanProvider>();
      final entry = await provider.getStudyPlanEntryById(entryId);

      if (entry != null && mounted) {
        _initializeFromEntry(entry);
        setState(() {
          // Update UI with loaded data
        });
      }
    } catch (e) {
      // Handle error loading entry
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading study plan entry: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.editingEntry != null;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false); // Return false if user uses back
        return false;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Edit Study Plan' : 'New Study Plan'),
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Delete Entry',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubjectField(),
                const SizedBox(height: 16),
                _buildProjectDropdown(),
                const SizedBox(height: 16),
                _buildDateSection(),
                const SizedBox(height: 16),
                _buildTimeSection(),
                const SizedBox(height: 16),
                _buildReminderSection(),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      decoration: const InputDecoration(
        labelText: 'Subject/Topic',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.subject),
      ),
      style: const TextStyle(color: AppColors.textColor),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a subject or topic';
        }
        return null;
      },
    );
  }

  Widget _buildProjectDropdown() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        final projects = projectProvider.projects;

        return DropdownButtonFormField<String>(
          value: _selectedProjectId,
          decoration: const InputDecoration(
            labelText: 'Link to Project (Optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.folder),
          ),
          style: const TextStyle(color: AppColors.textColor),
          dropdownColor: AppColors.cardColor,
          isExpanded: true, // Fix for unbounded width constraints
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('No Project'),
            ),
            ...projects.map(
              (project) => DropdownMenuItem<String>(
                value: project.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Fix for unbounded width
                  children: [
                    CircleAvatar(backgroundColor: project.color, radius: 8),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedProjectId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildDateSection() {
    final formatter = DateFormat('EEEE, MMMM d, y');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Date',
          style: TextStyle(
            color: AppColors.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatter.format(_selectedDate),
                    style: const TextStyle(color: AppColors.textColor),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Time',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: _isAllDay,
                  onChanged: (value) {
                    setState(() {
                      _isAllDay = value ?? false;
                      if (_isAllDay) {
                        _startTime = null;
                        _endTime = null;
                      }
                    });
                  },
                ),
                const Text(
                  'All Day',
                  style: TextStyle(color: AppColors.textColor),
                ),
              ],
            ),
          ],
        ),
        if (!_isAllDay) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Start Time',
                  time: _startTime,
                  onTap: () => _pickTime(isStartTime: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  label: 'End Time',
                  time: _endTime,
                  onTap: () => _pickTime(isStartTime: false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required DateTime? time,
    required VoidCallback onTap,
  }) {
    final formatter = DateFormat.jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.secondaryTextColor, fontSize: 12),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.textColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    time != null ? formatter.format(time) : 'Not set',
                    style: TextStyle(
                      color:
                          time != null
                              ? AppColors.textColor
                              : AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    final formatter = DateFormat('MMM d, y - h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder',
          style: TextStyle(
            color: AppColors.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickReminderTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: AppColors.textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _reminderDateTime != null
                        ? formatter.format(_reminderDateTime!)
                        : 'No reminder set',
                    style: TextStyle(
                      color:
                          _reminderDateTime != null
                              ? AppColors.textColor
                              : AppColors.secondaryTextColor,
                    ),
                  ),
                ),
                if (_reminderDateTime != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _reminderDateTime = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      style: const TextStyle(color: AppColors.textColor),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(_isEditing ? 'Update Study Plan' : 'Create Study Plan'),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final now = DateTime.now();
    final initialTime =
        isStartTime
            ? TimeOfDay.fromDateTime(_startTime ?? now)
            : TimeOfDay.fromDateTime(_endTime ?? now);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (pickedTime != null) {
      final pickedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isStartTime) {
          _startTime = pickedDateTime;
          // If end time is before start time, clear it
          if (_endTime != null && _endTime!.isBefore(_startTime!)) {
            _endTime = null;
          }
        } else {
          // Validate end time is after start time
          if (_startTime != null && pickedDateTime.isBefore(_startTime!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time must be after start time'),
              ),
            );
            return;
          }
          _endTime = pickedDateTime;
        }
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final now = DateTime.now();
    final initialDate = _reminderDateTime ?? _selectedDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: _selectedDate.add(const Duration(days: 1)),
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

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? now),
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

      if (pickedTime != null) {
        final reminderDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _reminderDateTime = reminderDateTime;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<StudyPlanProvider>();

      final entry = StudyPlanEntry(
        id: widget.editingEntry?.id,
        subjectName: _subjectController.text.trim(),
        projectId: _selectedProjectId,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        isAllDay: _isAllDay,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        reminderDateTime: _reminderDateTime,
        isCompleted: widget.editingEntry?.isCompleted ?? false,
        createdAt: widget.editingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await provider.updateStudyPlanEntry(entry);
      } else {
        success = await provider.addStudyPlanEntry(entry);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Failed to update study plan entry'
                  : 'Failed to create study plan entry',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardColor,
            title: const Text(
              'Delete Study Plan',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: const Text(
              'Are you sure you want to delete this study plan entry? This action cannot be undone.',
              style: TextStyle(color: AppColors.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await context
            .read<StudyPlanProvider>()
            .deleteStudyPlanEntry(widget.editingEntry!.id);

        if (success && mounted) {
          Navigator.of(context).pop(true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete study plan entry'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
