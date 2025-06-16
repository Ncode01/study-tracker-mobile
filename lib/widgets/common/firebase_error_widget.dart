import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../utils/firebase_error_translator.dart';

/// Error app shown when Firebase initialization fails
class FirebaseErrorApp extends StatelessWidget {
  final Object? error;

  const FirebaseErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Atlas - Error',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FirebaseErrorScreen(error: error),
    );
  }
}

/// Screen shown when Firebase fails to initialize
class FirebaseErrorScreen extends StatelessWidget {
  final Object? error;

  const FirebaseErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
        title: Text(
          'Project Atlas - Configuration Error',
          style: TextStyle(
            color: AppColors.errorRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.errorRed,
                ),
              ),

              const SizedBox(height: 32),

              // Error title
              Text(
                'Firebase Initialization Failed',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error description
              Text(
                'The app could not connect to Firebase. This usually means the configuration files are missing or incorrect.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.fadeGray,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Error details (collapsible)
              if (error != null) ...[
                ExpansionTile(
                  title: Text(
                    'Technical Details',
                    style: TextStyle(
                      color: AppColors.fadeGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        FirebaseErrorTranslator.translateGenericError(error!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32), // Solution steps
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to fix this:',
                          style: TextStyle(
                            color: AppColors.primaryBrown,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Ensure google-services.json is in android/app/\n'
                      '2. Ensure GoogleService-Info.plist is in ios/Runner/\n'
                      '3. Run "flutterfire configure" to set up Firebase\n'
                      '4. Restart the app after configuration',
                      style: TextStyle(color: AppColors.fadeGray, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: () {
                  // Simple restart attempt - in a real app, you might implement hot restart
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
