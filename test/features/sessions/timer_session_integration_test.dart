import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/analytics/providers/analytics_provider.dart';
import 'package:study/src/features/goals/providers/goal_provider.dart';
import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/settings/providers/settings_provider.dart';
import 'package:study/src/features/timer/providers/timer_service_provider.dart';
import 'package:study/src/features/tasks/providers/task_provider.dart';
import 'package:study/src/providers/project_provider.dart';
import 'package:study/src/services/database_helper.dart';
import 'package:study/src/features/settings/services/settings_service.dart';
import 'package:study/src/models/project_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Saving a session via timer updates sessions, analytics, and goals',
    (WidgetTester tester) async {
      // Build widget tree with all providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProjectProvider()),
            ChangeNotifierProvider(create: (_) => SessionProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => TimerServiceProvider()),
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(SettingsService()),
            ),
            ChangeNotifierProxyProvider2<
              SettingsProvider,
              SessionProvider,
              AnalyticsProvider
            >(
              create:
                  (context) => AnalyticsProvider(
                    DatabaseHelper.instance,
                    Provider.of<SettingsProvider>(context, listen: false),
                  ),
              update: (context, settings, session, prev) {
                prev ??= AnalyticsProvider(DatabaseHelper.instance, settings);
                prev.refreshAnalytics();
                return prev;
              },
            ),
            ChangeNotifierProxyProvider3<
              SessionProvider,
              TaskProvider,
              ProjectProvider,
              GoalProvider
            >(
              create:
                  (context) => GoalProvider(
                    Provider.of<SessionProvider>(context, listen: false),
                    Provider.of<TaskProvider>(context, listen: false),
                    Provider.of<ProjectProvider>(context, listen: false),
                  ),
              update: (context, session, task, project, prev) {
                prev ??= GoalProvider(session, task, project);
                prev.sessionProvider = session;
                prev.taskProvider = task;
                prev.projectProvider = project;
                prev.updateGoalProgress();
                return prev;
              },
            ),
          ],
          child: Builder(
            builder: (context) {
              // Add a test project
              final projectProv = Provider.of<ProjectProvider>(
                context,
                listen: false,
              );
              final project = Project(
                id: 'test',
                name: 'Test',
                color: Colors.blue,
                loggedMinutes: 0,
                goalMinutes: 60,
              );
              projectProv.addProject(project);

              // Simulate timer start and stop
              final timerService = Provider.of<TimerServiceProvider>(
                context,
                listen: false,
              );
              timerService.startTimer(project, context);
              return Container();
            },
          ),
        ),
      );

      // Let a bit of time pass
      await tester.pump(Duration(milliseconds: 10));
      // Stop timer
      final containerContext = tester.element(find.byType(Container));
      final timerService = Provider.of<TimerServiceProvider>(
        containerContext,
        listen: false,
      );
      await timerService.stopTimer(containerContext);

      // Wait for providers to update
      await tester.pumpAndSettle();

      // Verify session saved
      final sessionProv = Provider.of<SessionProvider>(
        containerContext,
        listen: false,
      );
      expect(sessionProv.sessions.isNotEmpty, true);

      // Verify analytics updated
      final analyticsProv = Provider.of<AnalyticsProvider>(
        containerContext,
        listen: false,
      );
      expect(analyticsProv.studyAverages, isNotNull);

      // Verify goal progress updated
      final goalProv = Provider.of<GoalProvider>(
        containerContext,
        listen: false,
      );
      expect(goalProv.shortTermGoals, isNotEmpty);
    },
  );
}
