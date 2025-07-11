import '../domain/models/subject_model.dart';
import '../domain/repositories/subject_repository.dart';
import 'hive_data_service.dart';

/// Persistent implementation of [SubjectRepository] using Hive
/// Replaces the in-memory implementation with robust local storage
class HiveSubjectRepositoryImpl implements SubjectRepository {
  /// Initialize with default subjects if the box is empty
  /// This ensures a good first-time user experience
  Future<void> _initializeDefaultSubjects() async {
    final box = HiveDataService.subjectsBox;

    // Only add default subjects if the box is empty (first launch)
    if (box.isEmpty) {
      final defaultSubjects = [
        Subject(id: 'math_001', name: 'Mathematics'),
        Subject(id: 'cs_001', name: 'Computer Science'),
        Subject(id: 'physics_001', name: 'Physics'),
        Subject(id: 'chemistry_001', name: 'Chemistry'),
        Subject(id: 'biology_001', name: 'Biology'),
      ];

      for (final subject in defaultSubjects) {
        await box.put(subject.id, subject);
      }
    }
  }

  @override
  Future<List<Subject>> getSubjects() async {
    await _initializeDefaultSubjects();
    final box = HiveDataService.subjectsBox;
    return box.values.toList();
  }

  @override
  Future<void> addSubject(Subject subject) async {
    final box = HiveDataService.subjectsBox;
    await box.put(subject.id, subject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final box = HiveDataService.subjectsBox;
    await box.put(subject.id, subject);
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    final box = HiveDataService.subjectsBox;
    await box.delete(subjectId);
  }

  /// Get a specific subject by ID
  Future<Subject?> getSubjectById(String id) async {
    final box = HiveDataService.subjectsBox;
    return box.get(id);
  }

  /// Check if a subject exists by ID
  Future<bool> subjectExists(String id) async {
    final box = HiveDataService.subjectsBox;
    return box.containsKey(id);
  }

  /// Get subjects count for analytics
  Future<int> getSubjectsCount() async {
    final box = HiveDataService.subjectsBox;
    return box.length;
  }

  /// Clear all subjects (useful for testing or reset functionality)
  Future<void> clearAllSubjects() async {
    final box = HiveDataService.subjectsBox;
    await box.clear();
  }
}
