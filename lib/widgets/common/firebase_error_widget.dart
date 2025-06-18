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
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Error icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 60,
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
                                color: AppColors.errorRed.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              FirebaseErrorTranslator.translateGenericError(
                                error!,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Solution steps
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
                            style: TextStyle(
                              color: AppColors.fadeGray,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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

/// Generic error widget for displaying Firebase operation errors
class FirebaseErrorWidget extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;
  final bool showTechnicalDetails;

  const FirebaseErrorWidget({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
    this.showTechnicalDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userMessage = FirebaseErrorTranslator.translateGenericError(error);
    final suggestedAction = FirebaseErrorTranslator.getSuggestedAction(error);
    final isRetryable = FirebaseErrorTranslator.isRetryableError(error);

    return Card(
      color: AppColors.errorRed.withValues(alpha: 0.05),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.errorRed, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ?? 'Operation Failed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User-friendly error message
            Text(
              userMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Suggested action
            Text(
              suggestedAction,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.fadeGray,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Technical details (if enabled)
            if (showTechnicalDetails) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  'Technical Details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.fadeGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Action buttons
            if (onRetry != null && isRetryable) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error display for form fields and smaller UI components
class InlineErrorWidget extends StatelessWidget {
  final Object error;
  final IconData? icon;

  const InlineErrorWidget({super.key, required this.error, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userMessage = FirebaseErrorTranslator.translateGenericError(error);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.warning_amber_rounded,
            color: AppColors.errorRed,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              userMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Snackbar for temporary error notifications
class ErrorSnackBar {
  static void show(BuildContext context, Object error) {
    final userMessage = FirebaseErrorTranslator.translateGenericError(error);
    final isRetryable = FirebaseErrorTranslator.isRetryableError(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorRed,
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                userMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action:
            isRetryable
                ? SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () {
                    // Retry callback would be handled by the calling widget
                  },
                )
                : null,
        duration: Duration(seconds: isRetryable ? 7 : 4),
      ),
    );
  }
}
