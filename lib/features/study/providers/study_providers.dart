import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hive_subject_repository_impl.dart';
import '../data/hive_study_session_repository_impl.dart';
import '../domain/repositories/subject_repository.dart';
import '../domain/repositories/study_session_repository.dart';
import '../domain/models/subject_model.dart';
import '../domain/models/study_session_model.dart';

// Rebuilt: Provider for the persistent subject repository using Hive
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return HiveSubjectRepositoryImpl();
});

// Rebuilt: Provider for the persistent study session repository using Hive
final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return HiveStudySessionRepositoryImpl();
});

// Rebuilt: Provider for the list of subjects with automatic persistence
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.getSubjects();
});

// Rebuilt: Provider for the list of study sessions with automatic persistence
final studyHistoryProvider = FutureProvider<List<StudySession>>((ref) async {
  final repo = ref.watch(studySessionRepositoryProvider);
  return repo.getStudySessions();
});

// Enhanced: Notifier for the currently active study session with persistence
class ActiveStudySessionNotifier extends StateNotifier<StudySession?> {
  final StudySessionRepository _repository;

  ActiveStudySessionNotifier(this._repository) : super(null);

  void startSession(StudySession session) {
    state = session;
  }

  void endSession() {
    state = null;
  }

  /// Save the current active session to storage
  Future<void> saveActiveSession() async {
    if (state != null) {
      await _repository.addStudySession(state!);
    }
  }

  /// End and save the current session
  Future<void> endAndSaveSession() async {
    await saveActiveSession();
    state = null;
  }
}

// Enhanced: Provider for active study session with persistence integration
final activeStudySessionProvider =
    StateNotifierProvider<ActiveStudySessionNotifier, StudySession?>((ref) {
      final repository = ref.watch(studySessionRepositoryProvider);
      return ActiveStudySessionNotifier(repository);
    });

// New: Provider for today's study sessions
final todaysStudySessionsProvider = FutureProvider<List<StudySession>>((
  ref,
) async {
  final repo =
      ref.watch(studySessionRepositoryProvider)
          as HiveStudySessionRepositoryImpl;
  return repo.getTodaysStudySessions();
});

// New: Provider for this week's study sessions
final thisWeeksStudySessionsProvider = FutureProvider<List<StudySession>>((
  ref,
) async {
  final repo =
      ref.watch(studySessionRepositoryProvider)
          as HiveStudySessionRepositoryImpl;
  return repo.getThisWeeksStudySessions();
});

// New: Provider for total study time
final totalStudyTimeProvider = FutureProvider<int>((ref) async {
  final repo =
      ref.watch(studySessionRepositoryProvider)
          as HiveStudySessionRepositoryImpl;
  return repo.getTotalStudyTime();
});

// New: Provider for study sessions count
final studySessionsCountProvider = FutureProvider<int>((ref) async {
  final repo =
      ref.watch(studySessionRepositoryProvider)
          as HiveStudySessionRepositoryImpl;
  return repo.getStudySessionsCount();
});

// New: Provider for subjects count
final subjectsCountProvider = FutureProvider<int>((ref) async {
  final repo =
      ref.watch(subjectRepositoryProvider) as HiveSubjectRepositoryImpl;
  return repo.getSubjectsCount();
});
