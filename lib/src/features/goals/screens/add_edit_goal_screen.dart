import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/goals/models/study_goal.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/features/goals/providers/goal_provider.dart';

class AddEditGoalScreen extends StatefulWidget {
  final StudyGoal? editingGoal;
  final bool isLongTerm;
  const AddEditGoalScreen({Key? key, this.editingGoal, this.isLongTerm = false})
    : super(key: key);

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  GoalType? _selectedGoalType;
  String? _title;
  String? _description;
  double? _targetHours;
  String? _selectedProjectId;
  double? _targetGPA;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.editingGoal != null) {
      _selectedGoalType = widget.editingGoal!.goalType;
      _title = widget.editingGoal!.title;
      _description = widget.editingGoal!.description;
      if (widget.editingGoal is WeeklyHoursGoal) {
        _targetHours = (widget.editingGoal as WeeklyHoursGoal).targetHours;
      } else if (widget.editingGoal is ChapterCompletionGoal) {
        _selectedProjectId =
            (widget.editingGoal as ChapterCompletionGoal).projectId;
      } else if (widget.editingGoal is SemesterGPAGoal) {
        _targetGPA = (widget.editingGoal as SemesterGPAGoal).targetGPA;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingGoal == null ? 'Add Goal' : 'Edit Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<GoalType>(
                value: _selectedGoalType,
                decoration: const InputDecoration(labelText: 'Goal Type'),
                items:
                    GoalType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_goalTypeToString(type)),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedGoalType = val),
                validator: (val) => val == null ? 'Select a goal type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (val) => _title = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => _description = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter a description'
                            : null,
              ),
              const SizedBox(height: 16),
              if (_selectedGoalType == GoalType.weeklyHours)
                TextFormField(
                  initialValue: _targetHours?.toString(),
                  decoration: const InputDecoration(labelText: 'Target Hours'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _targetHours = double.tryParse(val),
                  validator:
                      (val) =>
                          val == null || double.tryParse(val) == null
                              ? 'Enter a valid number'
                              : null,
                ),
              if (_selectedGoalType == GoalType.chapterCompletion)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProjectId,
                      decoration: const InputDecoration(labelText: 'Project'),
                      items:
                          projectProvider.projects
                              .map(
                                (project) => DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => _selectedProjectId = val),
                      validator:
                          (val) => val == null ? 'Select a project' : null,
                    ),
                  ],
                ),
              if (_selectedGoalType == GoalType.semesterGPA)
                TextFormField(
                  initialValue: _targetGPA?.toString(),
                  decoration: const InputDecoration(labelText: 'Target GPA'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _targetGPA = double.tryParse(val),
                  validator:
                      (val) =>
                          val == null || double.tryParse(val) == null
                              ? 'Enter a valid GPA'
                              : null,
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGoal,
                child: Text(
                  widget.editingGoal == null ? 'Save Goal' : 'Update Goal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _goalTypeToString(GoalType type) {
    switch (type) {
      case GoalType.weeklyHours:
        return 'Weekly Study Hours';
      case GoalType.chapterCompletion:
        return 'Chapter Completion';
      case GoalType.semesterGPA:
        return 'Semester GPA';
      case GoalType.unlockDestination:
        return 'Unlock Destination';
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate() || _selectedGoalType == null) return;
    final provider = Provider.of<GoalProvider>(context, listen: false);
    StudyGoal newGoal;
    switch (_selectedGoalType!) {
      case GoalType.weeklyHours:
        newGoal = WeeklyHoursGoal(
          title: _title!,
          description: _description!,
          targetHours: _targetHours ?? 5,
        );
        break;
      case GoalType.chapterCompletion:
        final project = Provider.of<ProjectProvider>(
          context,
          listen: false,
        ).projects.firstWhere((p) => p.id == _selectedProjectId);
        newGoal = ChapterCompletionGoal(
          title: _title!,
          description: _description!,
          projectId: project.id,
          targetSections: project.totalTaskCount,
        );
        break;
      case GoalType.semesterGPA:
        newGoal = SemesterGPAGoal(
          title: _title!,
          description: _description!,
          targetGPA: _targetGPA ?? 4.0,
        );
        break;
      case GoalType.unlockDestination:
        newGoal = UnlockDestinationGoal(
          title: _title!,
          description: _description!,
          destinationName: 'Paris', // Default or allow user to select
          hoursGoal: WeeklyHoursGoal(
            title: 'Unlock Destination',
            description: '',
            targetHours: 20,
          ),
        );
        break;
    }
    if (widget.editingGoal != null) {
      provider.updateGoal(newGoal);
    } else {
      provider.addGoal(newGoal, longTerm: widget.isLongTerm);
    }
    Navigator.pop(context);
  }
}
