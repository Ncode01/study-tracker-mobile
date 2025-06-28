import '../domain/models/subject_model.dart';
import '../domain/repositories/subject_repository.dart';

/// Local in-memory implementation of [SubjectRepository].
class LocalSubjectRepositoryImpl implements SubjectRepository {
  final List<Subject> _subjects = [
    // Add some mock subjects for testing
    Subject(id: '1', name: 'Mathematics'),
    Subject(id: '2', name: 'Computer Science'),
    Subject(id: '3', name: 'Physics'),
  ];

  @override
  Future<List<Subject>> getSubjects() async {
    return _subjects;
  }

  @override
  Future<void> addSubject(Subject subject) async {
    _subjects.add(subject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.id == subjectId);
  }
}
