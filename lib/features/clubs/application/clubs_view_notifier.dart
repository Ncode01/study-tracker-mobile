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

class ClubProject {
  const ClubProject({
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
    required String? clubId,
    required String? projectId,
    required this.status,
    required this.title,
    required this.dueLabel,
    required this.estimateLabel,
    required this.progress,
  }) : _clubId = clubId,
       _projectId = projectId;

  final int? id;
  final String? _clubId;
  final String? _projectId;
  String get clubId => _clubId ?? 'general';
  String get projectId => _projectId ?? 'general';
  final ClubTaskStatus status;
  final String title;
  final String dueLabel;
  final String estimateLabel;
  final double progress;

  ClubTask copyWith({
    int? id,
    String? clubId,
    String? projectId,
    ClubTaskStatus? status,
    String? title,
    String? dueLabel,
    String? estimateLabel,
    double? progress,
  }) {
    return ClubTask(
      id: id ?? this.id,
      clubId: clubId ?? _clubId,
      projectId: projectId ?? _projectId,
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
    Map<String, List<ClubProject>>? projectsByClubId,
    required this.tasks,
    required this.selectedClubId,
    required this.selectedProjectId,
  }) : _projectsByClubId = projectsByClubId;

  static const ClubOption _fallbackClub = ClubOption(
    id: 'general',
    title: 'General',
    icon: Icons.groups_outlined,
    accentColor: Color(0xFF64748B),
  );

  static const ClubProject _fallbackProject = ClubProject(
    id: 'general',
    title: 'General',
    icon: Icons.apps_rounded,
    accentColor: Color(0xFF64748B),
  );

  final List<ClubOption> clubs;
  final Map<String, List<ClubProject>>? _projectsByClubId;
  final List<ClubTask> tasks;
  final String selectedClubId;
  final String selectedProjectId;

  Map<String, List<ClubProject>> get projectsByClubId =>
      _projectsByClubId ?? const <String, List<ClubProject>>{};

  ClubOption get selectedClub {
    if (clubs.isEmpty) {
      return _fallbackClub;
    }
    return clubs.firstWhere(
      (ClubOption club) => club.id == selectedClubId,
      orElse: () => clubs.first,
    );
  }

  List<ClubProject> get selectedProjects =>
      projectsByClubId[selectedClubId] ?? const <ClubProject>[];

  ClubProject get selectedProject => selectedProjects.firstWhere(
    (ClubProject project) => project.id == selectedProjectId,
    orElse:
        () =>
            selectedProjects.isNotEmpty
                ? selectedProjects.first
                : _fallbackProject,
  );

  ClubsViewState copyWith({
    List<ClubOption>? clubs,
    Map<String, List<ClubProject>>? projectsByClubId,
    List<ClubTask>? tasks,
    String? selectedClubId,
    String? selectedProjectId,
  }) {
    return ClubsViewState(
      clubs: clubs ?? this.clubs,
      projectsByClubId: projectsByClubId ?? this.projectsByClubId,
      tasks: tasks ?? this.tasks,
      selectedClubId: selectedClubId ?? this.selectedClubId,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
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

    final Map<String, List<ClubProject>> projectsByClubId =
        <String, List<ClubProject>>{
          'robotics': const <ClubProject>[
            ClubProject(
              id: 'general',
              title: 'General',
              icon: Icons.apps_rounded,
              accentColor: Color(0xFF3B82F6),
            ),
            ClubProject(
              id: 'chassis',
              title: 'Chassis',
              icon: Icons.smart_toy_outlined,
              accentColor: Color(0xFF3B82F6),
            ),
            ClubProject(
              id: 'electronics',
              title: 'Electronics',
              icon: Icons.memory_rounded,
              accentColor: Color(0xFF3B82F6),
            ),
          ],
          'debate': const <ClubProject>[
            ClubProject(
              id: 'general',
              title: 'General',
              icon: Icons.apps_rounded,
              accentColor: Color(0xFFF43F5E),
            ),
            ClubProject(
              id: 'cases',
              title: 'Cases',
              icon: Icons.gavel_rounded,
              accentColor: Color(0xFFF43F5E),
            ),
            ClubProject(
              id: 'speech',
              title: 'Speech',
              icon: Icons.mic_rounded,
              accentColor: Color(0xFFF43F5E),
            ),
          ],
          'hackathon': const <ClubProject>[
            ClubProject(
              id: 'general',
              title: 'General',
              icon: Icons.apps_rounded,
              accentColor: Color(0xFF22C55E),
            ),
            ClubProject(
              id: 'product',
              title: 'Product',
              icon: Icons.rocket_launch_rounded,
              accentColor: Color(0xFF22C55E),
            ),
            ClubProject(
              id: 'pitch',
              title: 'Pitch',
              icon: Icons.campaign_rounded,
              accentColor: Color(0xFF22C55E),
            ),
          ],
        };

    final List<ClubTask> mappedTasks = tasks
        .map(_mapStudyTask)
        .map(
          (ClubTask task) => task.copyWith(
            projectId: _normalizedProjectId(
              clubId: task.clubId,
              candidateProjectId: task.projectId,
              projectsByClubId: projectsByClubId,
            ),
          ),
        )
        .toList(growable: false);

    final String selectedClubId = 'robotics';
    final String selectedProjectId =
        (projectsByClubId[selectedClubId] ?? const <ClubProject>[]).first.id;

    return ClubsViewState(
      clubs: clubs,
      projectsByClubId: projectsByClubId,
      tasks: mappedTasks,
      selectedClubId: selectedClubId,
      selectedProjectId: selectedProjectId,
    );
  }

  void selectClub(String clubId) {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final List<ClubProject> projects =
        current.projectsByClubId[clubId] ?? const <ClubProject>[];
    final String selectedProjectId =
        projects.isNotEmpty ? projects.first.id : 'general';

    state = AsyncData(
      current.copyWith(
        selectedClubId: clubId,
        selectedProjectId: selectedProjectId,
      ),
    );
  }

  void selectProject(String projectId) {
    final ClubsViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final Set<String> projectIds =
        (current.projectsByClubId[current.selectedClubId] ??
                const <ClubProject>[])
            .map((ClubProject project) => project.id)
            .toSet();
    if (!projectIds.contains(projectId)) {
      return;
    }

    state = AsyncData(current.copyWith(selectedProjectId: projectId));
  }

  Future<void> createTask({
    required String clubId,
    required String projectId,
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

    final String normalizedProjectId = _normalizedProjectId(
      clubId: clubId,
      candidateProjectId: projectId,
      projectsByClubId: current.projectsByClubId,
    );

    final int normalizedEstimateMinutes = estimateMinutes.clamp(1, 480);
    final int tempId = _tempTaskIdSeed;
    _tempTaskIdSeed -= 1;

    final ClubTask optimisticTask = ClubTask(
      id: tempId,
      clubId: clubId,
      projectId: normalizedProjectId,
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
        projectId: normalizedProjectId,
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
    final double nextProgress = _progressForStatus(status);
    final List<ClubTask> optimisticTasks = current.tasks
        .map(
          (ClubTask task) =>
              task.id == taskId
                  ? task.copyWith(status: status, progress: nextProgress)
                  : task,
        )
        .toList(growable: false);

    state = AsyncData(current.copyWith(tasks: optimisticTasks));

    try {
      await _repository.updateTaskStatus(
        taskId: taskId,
        status: _statusValue(status),
        progress: nextProgress,
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
      projectId: task.projectId,
      status: status,
      title: task.title,
      dueLabel: task.dueLabel,
      estimateLabel: task.estimateLabel,
      progress: task.progress,
    );
  }

  String _normalizedProjectId({
    required String clubId,
    required String candidateProjectId,
    required Map<String, List<ClubProject>> projectsByClubId,
  }) {
    final List<ClubProject> projects =
        projectsByClubId[clubId] ?? const <ClubProject>[];
    if (projects.isEmpty) {
      return 'general';
    }
    final Set<String> projectIds =
        projects.map((ClubProject project) => project.id).toSet();
    if (projectIds.contains(candidateProjectId)) {
      return candidateProjectId;
    }
    return projects.first.id;
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
