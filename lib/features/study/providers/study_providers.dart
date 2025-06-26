import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_subject_repository_impl.dart';
import '../data/local_study_session_repository_impl.dart';
import '../domain/repositories/subject_repository.dart';
import '../domain/repositories/study_session_repository.dart';
import '../domain/models/subject_model.dart';
import '../domain/models/study_session_model.dart';

// Provider for the subject repository
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return LocalSubjectRepositoryImpl();
});

// Provider for the study session repository
final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return LocalStudySessionRepositoryImpl();
});

// Provider for the list of subjects
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.getSubjects();
});

// Provider for the list of study sessions (study history)
final studyHistoryProvider = FutureProvider<List<StudySession>>((ref) async {
  final repo = ref.watch(studySessionRepositoryProvider);
  return repo.getStudySessions();
});

// Notifier for the currently active study session
class ActiveStudySessionNotifier extends StateNotifier<StudySession?> {
  ActiveStudySessionNotifier() : super(null);

  void startSession(StudySession session) {
    state = session;
  }

  void endSession() {
    state = null;
  }
}

final activeStudySessionProvider =
    StateNotifierProvider<ActiveStudySessionNotifier, StudySession?>(
      (ref) => ActiveStudySessionNotifier(),
    );
