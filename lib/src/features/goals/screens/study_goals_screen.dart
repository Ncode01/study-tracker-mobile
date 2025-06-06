import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/goals/widgets/goal_card.dart';
import 'package:study/src/features/goals/widgets/dynamic_goal_card.dart';
import 'package:study/src/features/goals/providers/goal_provider.dart';
import 'package:study/src/features/goals/screens/add_edit_goal_screen.dart';
import 'package:study/src/features/settings/screens/settings_screen.dart';

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
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Personal Goals
                        Text(
                          'Personal Goals',
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
                              ...longTermGoals.map(
                                (goal) => GoalCard(
                                  goal: goal,
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => AddEditGoalScreen(
                                                editingGoal: goal,
                                                isLongTerm: true,
                                              ),
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Personal Goal'),
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const AddEditGoalScreen(
                                              isLongTerm: true,
                                            ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Short-term Goals
                        Text(
                          'Dynamic Short-term Goals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (goalProvider.dynamicShortTermGoals.isEmpty)
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: Text(
                              'No dynamic goals at the moment! 🎉',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Column(
                            children:
                                goalProvider.dynamicShortTermGoals
                                    .map((goal) => DynamicGoalCard(goal: goal))
                                    .toList(),
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
