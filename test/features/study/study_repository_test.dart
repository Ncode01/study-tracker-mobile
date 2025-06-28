import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/study/domain/models/subject_model.dart';
import 'package:study/features/study/domain/models/study_session_model.dart';
import 'package:study/features/study/data/local_subject_repository_impl.dart';
import 'package:study/features/study/data/local_study_session_repository_impl.dart';

void main() {
  group('LocalSubjectRepositoryImpl', () {
    test('can add and retrieve subjects', () async {
      final repo = LocalSubjectRepositoryImpl();
      final subject = Subject(id: '1', name: 'Math');
      await repo.addSubject(subject);
      final subjects = await repo.getSubjects();
      expect(subjects, contains(subject));
    });
  });

  group('LocalStudySessionRepositoryImpl', () {
    test('can add and retrieve study sessions', () async {
      final repo = LocalStudySessionRepositoryImpl();
      final session = StudySession(
        id: '1',
        subjectId: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: 60)),
        durationMinutes: 60,
        notes: 'Test session',
      );
      await repo.addStudySession(session);
      final sessions = await repo.getStudySessions();
      expect(sessions, contains(session));
    });
  });
}
