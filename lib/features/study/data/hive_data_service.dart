import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../domain/models/subject_model.dart';
import '../domain/models/study_session_model.dart';

/// Centralized Hive initialization and configuration service
/// Handles database setup, adapters registration, and box management
class HiveDataService {
  static const String _subjectsBoxName = 'subjects';
  static const String _studySessionsBoxName = 'study_sessions';
  static const String _userPreferencesBoxName = 'user_preferences';

  static bool _isInitialized = false;
  static final Logger _logger = Logger();

  /// Initialize Hive database with required adapters and boxes
  /// Must be called before using any Hive operations
  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.i('HiveDataService already initialized');
      return;
    }

    try {
      _logger.i('Initializing HiveDataService...');

      // Initialize Hive for Flutter
      await Hive.initFlutter();
      _logger.i('Hive initialized for Flutter');

      // Register type adapters for our models
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SubjectAdapter());
        _logger.i('Subject adapter registered');
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StudySessionAdapter());
        _logger.i('StudySession adapter registered');
      }

      // Open required boxes
      await openBoxes();
      _logger.i('All Hive boxes opened successfully');

      _isInitialized = true;
      _logger.i('HiveDataService initialization complete');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize HiveDataService',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  /// Open all required Hive boxes for the application
  static Future<void> openBoxes() async {
    try {
      await Future.wait([
        Hive.openBox<Subject>(_subjectsBoxName),
        Hive.openBox<StudySession>(_studySessionsBoxName),
        Hive.openBox<dynamic>(_userPreferencesBoxName),
      ]);
      _logger.i('All boxes opened successfully');
    } catch (e) {
      _logger.e('Failed to open Hive boxes', error: e);
      rethrow;
    }
  }

  /// Get the subjects box for CRUD operations
  static Box<Subject> get subjectsBox {
    _ensureInitialized();
    return Hive.box<Subject>(_subjectsBoxName);
  }

  /// Get the study sessions box for CRUD operations
  static Box<StudySession> get studySessionsBox {
    _ensureInitialized();
    return Hive.box<StudySession>(_studySessionsBoxName);
  }

  /// Get the user preferences box for app settings
  static Box<dynamic> get userPreferencesBox {
    _ensureInitialized();
    return Hive.box<dynamic>(_userPreferencesBoxName);
  }

  /// Check if Hive is properly initialized
  static bool get isInitialized => _isInitialized;

  /// Close all Hive boxes (useful for testing or app shutdown)
  static Future<void> closeBoxes() async {
    try {
      if (_isInitialized) {
        await Future.wait([
          Hive.box<Subject>(_subjectsBoxName).close(),
          Hive.box<StudySession>(_studySessionsBoxName).close(),
          Hive.box<dynamic>(_userPreferencesBoxName).close(),
        ]);
        _logger.i('All Hive boxes closed successfully');
      }
    } catch (e) {
      _logger.e('Error closing Hive boxes', error: e);
      rethrow;
    }
  }

  /// Clear all data from all boxes (useful for testing or reset functionality)
  static Future<void> clearAllData() async {
    try {
      _ensureInitialized();
      await Future.wait([
        subjectsBox.clear(),
        studySessionsBox.clear(),
        userPreferencesBox.clear(),
      ]);
      _logger.i('All data cleared from Hive boxes');
    } catch (e) {
      _logger.e('Error clearing data from Hive boxes', error: e);
      rethrow;
    }
  }

  /// Ensure Hive is initialized before performing operations
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveDataService must be initialized before use. Call HiveDataService.initialize() first.',
      );
    }
  }

  /// Get storage information for debugging
  static Future<Map<String, dynamic>> getStorageInfo() async {
    _ensureInitialized();

    try {
      return {
        'subjectsCount': subjectsBox.length,
        'studySessionsCount': studySessionsBox.length,
        'userPreferencesCount': userPreferencesBox.length,
        'isInitialized': _isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error getting storage info', error: e);
      rethrow;
    }
  }

  /// Backup data to a map (useful for data migration)
  static Future<Map<String, dynamic>> backupData() async {
    _ensureInitialized();

    try {
      final subjects = subjectsBox.values.map((s) => s.toJson()).toList();
      final sessions = studySessionsBox.values.map((s) => s.toJson()).toList();
      final preferences = Map<String, dynamic>.from(userPreferencesBox.toMap());

      return {
        'subjects': subjects,
        'studySessions': sessions,
        'userPreferences': preferences,
        'backupTimestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error backing up data', error: e);
      rethrow;
    }
  }

  /// Restore data from a backup map (useful for data migration)
  static Future<void> restoreData(Map<String, dynamic> backupData) async {
    _ensureInitialized();

    try {
      // Clear existing data
      await clearAllData();

      // Restore subjects
      if (backupData['subjects'] != null) {
        final subjects =
            (backupData['subjects'] as List)
                .map((json) => Subject.fromJson(json))
                .toList();
        for (final subject in subjects) {
          await subjectsBox.put(subject.id, subject);
        }
      }

      // Restore study sessions
      if (backupData['studySessions'] != null) {
        final sessions =
            (backupData['studySessions'] as List)
                .map((json) => StudySession.fromJson(json))
                .toList();
        for (final session in sessions) {
          await studySessionsBox.put(session.id, session);
        }
      }

      // Restore user preferences
      if (backupData['userPreferences'] != null) {
        final preferences =
            backupData['userPreferences'] as Map<String, dynamic>;
        for (final entry in preferences.entries) {
          await userPreferencesBox.put(entry.key, entry.value);
        }
      }

      _logger.i('Data restored successfully from backup');
    } catch (e) {
      _logger.e('Error restoring data from backup', error: e);
      rethrow;
    }
  }
}
