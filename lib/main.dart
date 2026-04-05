import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/core_providers.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_settings_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final AppSettingsService appSettingsService = AppSettingsService(
    preferences: preferences,
  );
  await appSettingsService.init();

  await NotificationService.instance.init(
    onTap: (String? payload) {
      if (payload != 'timer_complete') {
        return;
      }

      final BuildContext? context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.go('/');
        return;
      }

      appRouter.go('/');
    },
  );

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        appSettingsServiceProvider.overrideWithValue(appSettingsService),
      ],
      child: const TimeFlowApp(),
    ),
  );
}

class TimeFlowApp extends StatelessWidget {
  const TimeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TimeFlow',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
