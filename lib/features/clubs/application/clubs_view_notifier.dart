import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
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

  ClubTask copyWith({
    int? id,
    String? clubId,
    ClubTaskStatus? status,
    String? title,
    String? dueLabel,
    String? estimateLabel,
    double? progress,
  }) {
    return ClubTask(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      status: status ?? this.status,
      title: title ?? this.title,
      dueLabel: dueLabel ?? this.dueLabel,
      estimateLabel: estimateLabel ?? this.estimateLabel,
      progress: progress ?? this.progress,
    );
  }
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
  int _tempTaskIdSeed = -1;

  @override
  Future<ClubsViewState> build() async {
    _repository = TaskRepository(database: ref.read(databaseProvider));
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

  Future<void> createTask({
    required String clubId,
    required ClubTaskStatus status,
    required String title,
    required String dueLabel,
    required int estimateMinutes,
  }) async {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final String normalizedTitle = title.trim();
    final String normalizedDueLabel = dueLabel.trim();
    if (normalizedTitle.isEmpty || normalizedDueLabel.isEmpty) {
      return;
    }

    final int normalizedEstimateMinutes = estimateMinutes.clamp(1, 480);
    final int tempId = _tempTaskIdSeed;
    _tempTaskIdSeed -= 1;

    final ClubTask optimisticTask = ClubTask(
      id: tempId,
      clubId: clubId,
      status: status,
      title: normalizedTitle,
      dueLabel: normalizedDueLabel,
      estimateLabel: _estimateLabelForMinutes(normalizedEstimateMinutes),
      progress: _progressForStatus(status),
    );

    final List<ClubTask> originalTasks = current.tasks;
    state = AsyncData(
      current.copyWith(tasks: <ClubTask>[...current.tasks, optimisticTask]),
    );

    try {
      final StudyTask created = await _repository.createTask(
        clubId: clubId,
        status: _statusValue(status),
        title: normalizedTitle,
        dueLabel: normalizedDueLabel,
        estimateMinutes: normalizedEstimateMinutes,
        progress: _progressForStatus(status),
      );

      final ClubsViewState latest = state.valueOrNull ?? current;
      final List<ClubTask> tasks = latest.tasks
          .map(
            (ClubTask task) =>
                task.id == tempId ? _mapStudyTask(created) : task,
          )
          .toList(growable: false);

      state = AsyncData(latest.copyWith(tasks: tasks));
    } catch (_) {
      state = AsyncData(current.copyWith(tasks: originalTasks));
      rethrow;
    }
  }

  Future<void> updateTaskStatus({
    required int taskId,
    required ClubTaskStatus status,
  }) async {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final List<ClubTask> originalTasks = current.tasks;
    final List<ClubTask> optimisticTasks = current.tasks
        .map(
          (ClubTask task) =>
              task.id == taskId
                  ? task.copyWith(
                    status: status,
                    progress: _progressForStatus(status),
                  )
                  : task,
        )
        .toList(growable: false);

    state = AsyncData(current.copyWith(tasks: optimisticTasks));

    try {
      await _repository.updateTaskStatus(
        taskId: taskId,
        status: _statusValue(status),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(tasks: originalTasks));
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final List<ClubTask> originalTasks = current.tasks;
    final List<ClubTask> optimisticTasks = current.tasks
        .where((ClubTask task) => task.id != taskId)
        .toList(growable: false);

    state = AsyncData(current.copyWith(tasks: optimisticTasks));

    try {
      await _repository.deleteTask(taskId: taskId);
    } catch (_) {
      state = AsyncData(current.copyWith(tasks: originalTasks));
      rethrow;
    }
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

  String _statusValue(ClubTaskStatus status) {
    return switch (status) {
      ClubTaskStatus.todo => 'todo',
      ClubTaskStatus.doing => 'doing',
      ClubTaskStatus.done => 'done',
    };
  }

  double _progressForStatus(ClubTaskStatus status) {
    return switch (status) {
      ClubTaskStatus.todo => 0,
      ClubTaskStatus.doing => 0.35,
      ClubTaskStatus.done => 1,
    };
  }

  String _estimateLabelForMinutes(int estimateMinutes) {
    if (estimateMinutes >= 60) {
      final int hours = estimateMinutes ~/ 60;
      final int minutes = estimateMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${minutes}m';
    }
    return '${estimateMinutes}m';
  }
}
