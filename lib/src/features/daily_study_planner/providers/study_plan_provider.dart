import 'package:flutter/material.dart';
import 'package:study/src/models/study_plan_entry_model.dart';
import 'package:study/src/services/database_helper.dart';

/// Provider for managing daily study plan entries and database operations.
///
/// This provider follows the established architectural patterns of the application,
/// providing state management for StudyPlanEntry objects with comprehensive
/// CRUD operations, loading states, and error handling.
///
/// Features:
/// - CRUD operations for study plan entries
/// - Date-based filtering and querying
/// - Project-based filtering
/// - Loading states and error handling
/// - Automatic cache management
/// - Immutable state exposure
class StudyPlanProvider extends ChangeNotifier {
  // Private state variables
  List<StudyPlanEntry> _studyPlanEntries = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false; // Track disposal state

  // Public getters (immutable access)
  List<StudyPlanEntry> get studyPlanEntries =>
      List.unmodifiable(_studyPlanEntries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Constructor with automatic data loading
  StudyPlanProvider() {
    fetchStudyPlanEntries();
  }

  // ==================== Core CRUD Operations ====================

  /// Fetches all study plan entries from the database.
  /// Updates loading state and handles errors appropriately.
  Future<void> fetchStudyPlanEntries() async {
    _setLoading(true);
    _clearError();

    try {
      _studyPlanEntries =
          await DatabaseHelper.instance.getAllStudyPlanEntries();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load study plan entries: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new study plan entry to the database and updates local state.
  ///
  /// [entry] The StudyPlanEntry to add
  /// Returns true if successful, false otherwise
  Future<bool> addStudyPlanEntry(StudyPlanEntry entry) async {
    _clearError();

    try {
      await DatabaseHelper.instance.insertStudyPlanEntry(entry);
      await fetchStudyPlanEntries(); // Refresh local state
      return true;
    } catch (e) {
      _setError('Failed to add study plan entry: $e');
      return false;
    }
  }

  /// Updates an existing study plan entry in the database.
  ///
  /// [entry] The updated StudyPlanEntry
  /// Returns true if successful, false otherwise
  Future<bool> updateStudyPlanEntry(StudyPlanEntry entry) async {
    _clearError();

    try {
      await DatabaseHelper.instance.updateStudyPlanEntry(entry);
      await fetchStudyPlanEntries(); // Refresh local state
      return true;
    } catch (e) {
      _setError('Failed to update study plan entry: $e');
      return false;
    }
  }

  /// Deletes a study plan entry from the database.
  ///
  /// [entryId] The ID of the entry to delete
  /// Returns true if successful, false otherwise
  Future<bool> deleteStudyPlanEntry(String entryId) async {
    _clearError();

    try {
      await DatabaseHelper.instance.deleteStudyPlanEntry(entryId);
      await fetchStudyPlanEntries(); // Refresh local state
      return true;
    } catch (e) {
      _setError('Failed to delete study plan entry: $e');
      return false;
    }
  }

  /// Toggles the completion status of a study plan entry.
  ///
  /// [entry] The StudyPlanEntry to toggle
  /// Returns true if successful, false otherwise
  Future<bool> toggleEntryCompleted(StudyPlanEntry entry) async {
    final updatedEntry = entry.copyWith(isCompleted: !entry.isCompleted);
    return await updateStudyPlanEntry(updatedEntry);
  }

  // ==================== Filtered Getters ====================
  /// Gets all study plan entries for today.
  List<StudyPlanEntry> get todayEntries {
    final today = DateTime.now();
    return _studyPlanEntries.where((entry) {
      return entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day;
    }).toList();
  }

  /// Gets all completed study plan entries.
  List<StudyPlanEntry> get completedEntries {
    return _studyPlanEntries.where((entry) => entry.isCompleted).toList();
  }

  /// Gets all pending (incomplete) study plan entries.
  List<StudyPlanEntry> get pendingEntries {
    return _studyPlanEntries.where((entry) => !entry.isCompleted).toList();
  }

  /// Gets all overdue study plan entries.
  List<StudyPlanEntry> get overdueEntries {
    return _studyPlanEntries.where((entry) => entry.isOverdue).toList();
  }

  /// Gets study plan entries for a specific date.
  ///
  /// [date] The date to filter by
  List<StudyPlanEntry> getEntriesForDate(DateTime date) {
    return _studyPlanEntries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  /// Gets study plan entries for a specific project.
  ///
  /// [projectId] The project ID to filter by
  List<StudyPlanEntry> getEntriesForProject(String projectId) {
    return _studyPlanEntries
        .where((entry) => entry.projectId == projectId)
        .toList();
  }

  /// Gets study plan entries within a date range.
  ///
  /// [startDate] The start date (inclusive)
  /// [endDate] The end date (inclusive)
  List<StudyPlanEntry> getEntriesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _studyPlanEntries.where((entry) {
      final entryDate = entry.date;
      return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // ==================== Database Query Methods ====================
  /// Refreshes entries for a specific date from the database.
  /// Useful for targeted updates without full refresh.
  ///
  /// [date] The date to refresh entries for
  Future<void> refreshEntriesForDate(DateTime date) async {
    _clearError();

    try {
      final dateEntries = await DatabaseHelper.instance
          .getStudyPlanEntriesForDate(date);

      // Remove existing entries for this date
      _studyPlanEntries.removeWhere((entry) {
        return entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day;
      });

      // Add fresh entries
      _studyPlanEntries.addAll(dateEntries);
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh entries for date: $e');
    }
  }

  /// Refreshes entries for a specific project from the database.
  ///
  /// [projectId] The project ID to refresh entries for
  Future<void> refreshEntriesForProject(String projectId) async {
    _clearError();

    try {
      final projectEntries = await DatabaseHelper.instance
          .getStudyPlanEntriesForProject(projectId);

      // Remove existing entries for this project
      _studyPlanEntries.removeWhere((entry) => entry.projectId == projectId);

      // Add fresh entries
      _studyPlanEntries.addAll(projectEntries);
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh entries for project: $e');
    }
  }

  // ==================== Computed Properties ====================
  /// Gets the total planned study time for today in minutes.
  int get todayPlannedMinutes {
    return todayEntries.fold<int>(
      0,
      (sum, entry) => sum + (entry.durationMinutes ?? 0),
    );
  }

  /// Gets the total completed study time for today in minutes.
  int get todayCompletedMinutes {
    return todayEntries
        .where((entry) => entry.isCompleted)
        .fold<int>(0, (sum, entry) => sum + (entry.durationMinutes ?? 0));
  }

  /// Gets the completion percentage for today's entries.
  double get todayCompletionPercentage {
    final totalEntries = todayEntries.length;
    if (totalEntries == 0) return 0.0;

    final completedEntries =
        todayEntries.where((entry) => entry.isCompleted).length;
    return (completedEntries / totalEntries) * 100;
  }

  /// Gets the total number of overdue entries.
  int get overdueCount => overdueEntries.length;

  /// Checks if there are any entries planned for today.
  bool get hasEntriesToday => todayEntries.isNotEmpty;

  // ==================== Utility Methods ====================
  /// Creates a quick study plan entry for today.
  ///
  /// [subject] The subject to study
  /// [projectId] Optional project ID
  Future<bool> addQuickEntryForToday({
    required String subject,
    String? projectId,
  }) async {
    final entry = StudyPlanEntry(
      subjectName: subject,
      date: DateTime.now(),
      projectId: projectId,
    );

    return await addStudyPlanEntry(entry);
  }

  /// Duplicates an entry for a different date.
  ///
  /// [originalEntry] The entry to duplicate
  /// [newDate] The new date for the duplicated entry
  Future<bool> duplicateEntryForDate(
    StudyPlanEntry originalEntry,
    DateTime newDate,
  ) async {
    final duplicatedEntry = originalEntry.copyWith(
      id: null, // Will generate new ID
      date: newDate,
      isCompleted: false, // Reset completion status
    );

    return await addStudyPlanEntry(duplicatedEntry);
  }

  // ==================== Error Handling & State Management ====================  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    if (_disposed) return; // Prevent notifications after disposal
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message and notifies listeners.
  void _setError(String error) {
    if (_disposed) return; // Prevent notifications after disposal
    _error = error;
    notifyListeners();
  }

  /// Clears the current error state.
  void _clearError() {
    _error = null;
  }

  /// Clears the error state and notifies listeners.
  /// This method is public to allow UI to clear errors manually.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Checks if the provider has any error.
  bool get hasError => _error != null;

  // ==================== Resource Management ====================

  /// Disposes of resources when the provider is no longer needed.
  // (Removed duplicate dispose method.)

  /// Gets a study plan entry by ID.
  ///  /// [entryId] The ID of the entry to retrieve
  /// Returns the StudyPlanEntry if found, null otherwise
  Future<StudyPlanEntry?> getStudyPlanEntryById(String entryId) async {
    _clearError();

    try {
      return await DatabaseHelper.instance.getStudyPlanEntryById(entryId);
    } catch (e) {
      _setError('Failed to get study plan entry: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
