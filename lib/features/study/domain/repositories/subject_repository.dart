import '../models/subject_model.dart';

/// Abstract repository for managing study subjects.
abstract class SubjectRepository {
  Future<List<Subject>> getSubjects();
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);
}
