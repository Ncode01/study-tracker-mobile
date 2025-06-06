import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/goals/widgets/goal_card.dart';
import 'package:study/src/features/goals/widgets/destination_card.dart';
import 'package:study/src/features/goals/providers/goal_provider.dart';
import 'package:study/src/features/goals/models/study_goal.dart';

class StudyGoalsScreen extends StatefulWidget {
  const StudyGoalsScreen({super.key});

  @override
  State<StudyGoalsScreen> createState() => _StudyGoalsScreenState();
}

class _StudyGoalsScreenState extends State<StudyGoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<GoalProvider>(context, listen: false).fetchGoals(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme,
      child: Scaffold(
        body: Container(
          color: appTheme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Consumer<GoalProvider>(
              builder: (context, goalProvider, _) {
                final shortTermGoals = goalProvider.shortTermGoals;
                final longTermGoals = goalProvider.longTermGoals;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AppBar
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).cardTheme.shadowColor ??
                                  Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Theme.of(context).cardTheme.shadowColor
                                        ?.withOpacity(0.10) ??
                                    Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Spacer(),
                              Text(
                                'Study Goals',
                                style:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle,
                              ),
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                        // Short-Term Goals
                        Text(
                          'Short-Term Goals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).cardTheme.shadowColor ??
                                  Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Theme.of(context).cardTheme.shadowColor
                                        ?.withOpacity(0.10) ??
                                    Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ...shortTermGoals.map((goal) {
                                if (goal is WeeklyHoursGoal) {
                                  return GoalCard(
                                    icon: Icons.access_time,
                                    title: goal.title,
                                    description: goal.description,
                                    progress: goal.progress,
                                    progressLabel:
                                        '${goal.currentHours.toStringAsFixed(1)} / ${goal.targetHours} hrs',
                                  );
                                } else if (goal is ChapterCompletionGoal) {
                                  return GoalCard(
                                    icon: Icons.menu_book,
                                    title: goal.title,
                                    description: goal.description,
                                    progress: goal.progress,
                                    progressLabel:
                                        '${goal.completedSections} / ${goal.targetSections} sections',
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              const Divider(
                                height: 24,
                                color: Colors.transparent,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Short-Term Goal'),
                                  onPressed: null, // Placeholder for now
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Long-Term Goals
                        Text(
                          'Long-Term Goals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).cardTheme.shadowColor ??
                                  Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Theme.of(context).cardTheme.shadowColor
                                        ?.withOpacity(0.10) ??
                                    Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ...longTermGoals.map((goal) {
                                if (goal is SemesterGPAGoal) {
                                  return GoalCard(
                                    icon: Icons.school,
                                    title: goal.title,
                                    description: goal.description,
                                    progress: goal.progress,
                                    progressLabel:
                                        'Current: ${goal.currentGPA.toStringAsFixed(2)} GPA',
                                  );
                                } else if (goal is UnlockDestinationGoal) {
                                  return DestinationCard(
                                    title: goal.title,
                                    description: goal.description,
                                    progress: goal.hoursGoal.progress,
                                    progressLabel:
                                        '${goal.hoursGoal.currentHours.toStringAsFixed(1)} / ${goal.hoursGoal.targetHours} hrs',
                                    destinationName: goal.destinationName,
                                    journeyMilestones:
                                        goalProvider.journeyMilestones,
                                    achievements: goalProvider.achievements,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
