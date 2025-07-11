import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:study/features/study/domain/models/subject_model.dart';
import 'package:study/features/study/domain/models/study_session_model.dart';
import 'package:study/features/study/data/hive_subject_repository_impl.dart';
import 'package:study/features/study/data/hive_study_session_repository_impl.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing (in memory)
    Hive.init('./test/');

    // Register type adapters for our models
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubjectAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(StudySessionAdapter());
    }

    // Open test boxes
    await Hive.openBox<Subject>('test_subjects');
    await Hive.openBox<StudySession>('test_study_sessions');
    await Hive.openBox<dynamic>('test_user_preferences');
  });

  tearDownAll(() async {
    // Clear and close test boxes
    await Hive.box<Subject>('test_subjects').clear();
    await Hive.box<StudySession>('test_study_sessions').clear();
    await Hive.box<dynamic>('test_user_preferences').clear();

    await Hive.close();
  });

  group('HiveSubjectRepositoryImpl', () {
    test('can add and retrieve subjects with persistence', () async {
      final repo = HiveSubjectRepositoryImpl();
      final subject = Subject(id: 'test_1', name: 'Math');
      await repo.addSubject(subject);
      final subjects = await repo.getSubjects();
      expect(subjects.any((s) => s.id == subject.id), isTrue);
    });
  });
  group('HiveStudySessionRepositoryImpl', () {
    test('can add and retrieve study sessions with persistence', () async {
      final repo = HiveStudySessionRepositoryImpl();
      final session = StudySession(
        id: 'session_1',
        subjectId: 'test_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: 60)),
        durationMinutes: 60,
        notes: 'Test session',
      );
      await repo.addStudySession(session);
      final sessions = await repo.getStudySessions();
      expect(sessions.any((s) => s.id == session.id), isTrue);
    });
  });
}
