import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local/app_database.dart';
import '../domain/models/study_task.dart';
import '../domain/repositories/task_repository.dart';

enum ClubTaskStatus { doing, todo, done }

class ClubOption {
  const ClubOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
}

class ClubTask {
  const ClubTask({
    this.id,
    required this.clubId,
    required this.status,
    required this.title,
    required this.dueLabel,
    required this.estimateLabel,
    required this.progress,
  });

  final int? id;
  final String clubId;
  final ClubTaskStatus status;
  final String title;
  final String dueLabel;
  final String estimateLabel;
  final double progress;
}

class ClubsViewState {
  const ClubsViewState({
    required this.clubs,
    required this.tasks,
    required this.selectedClubId,
  });

  final List<ClubOption> clubs;
  final List<ClubTask> tasks;
  final String selectedClubId;

  ClubOption get selectedClub =>
      clubs.firstWhere((ClubOption club) => club.id == selectedClubId);

  ClubsViewState copyWith({
    List<ClubOption>? clubs,
    List<ClubTask>? tasks,
    String? selectedClubId,
  }) {
    return ClubsViewState(
      clubs: clubs ?? this.clubs,
      tasks: tasks ?? this.tasks,
      selectedClubId: selectedClubId ?? this.selectedClubId,
    );
  }
}

class ClubsViewNotifier extends AsyncNotifier<ClubsViewState> {
  late final TaskRepository _repository;

  @override
  Future<ClubsViewState> build() async {
    _repository = TaskRepository(database: AppDatabase.instance);
    final List<StudyTask> tasks = await _repository.loadTasks();

    final List<ClubOption> clubs = const <ClubOption>[
      ClubOption(
        id: 'robotics',
        title: 'Robotics',
        icon: Icons.precision_manufacturing_outlined,
        accentColor: Color(0xFF3B82F6),
      ),
      ClubOption(
        id: 'debate',
        title: 'Debate',
        icon: Icons.record_voice_over_outlined,
        accentColor: Color(0xFFF43F5E),
      ),
      ClubOption(
        id: 'hackathon',
        title: 'Hackathon',
        icon: Icons.code_outlined,
        accentColor: Color(0xFF22C55E),
      ),
    ];

    return ClubsViewState(
      clubs: clubs,
      tasks: tasks.map(_mapStudyTask).toList(growable: false),
      selectedClubId: 'robotics',
    );
  }

  void selectClub(String clubId) {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(selectedClubId: clubId));
  }

  ClubTask _mapStudyTask(StudyTask task) {
    final ClubTaskStatus status = switch (task.status) {
      'doing' => ClubTaskStatus.doing,
      'done' => ClubTaskStatus.done,
      _ => ClubTaskStatus.todo,
    };

    return ClubTask(
      id: task.id,
      clubId: task.clubId,
      status: status,
      title: task.title,
      dueLabel: task.dueLabel,
      estimateLabel: task.estimateLabel,
      progress: task.progress,
    );
  }
}
