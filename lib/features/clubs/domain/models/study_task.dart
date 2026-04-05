class StudyTask {
  const StudyTask({
    this.id,
    required this.clubId,
    required this.projectId,
    required this.status,
    required this.title,
    required this.dueLabel,
    required this.estimateMinutes,
    required this.progress,
  });

  final int? id;
  final String clubId;
  final String projectId;
  final String status;
  final String title;
  final String dueLabel;
  final int estimateMinutes;
  final double progress;

  String get estimateLabel {
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

  StudyTask copyWith({
    int? id,
    String? clubId,
    String? projectId,
    String? status,
    String? title,
    String? dueLabel,
    int? estimateMinutes,
    double? progress,
  }) {
    return StudyTask(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      title: title ?? this.title,
      dueLabel: dueLabel ?? this.dueLabel,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      progress: progress ?? this.progress,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'clubId': clubId,
      'projectId': projectId,
      'status': status,
      'title': title,
      'dueLabel': dueLabel,
      'estimateMinutes': estimateMinutes,
      'progress': progress,
    };
  }

  factory StudyTask.fromMap(Map<String, Object?> map) {
    return StudyTask(
      id: map['id'] as int?,
      clubId: map['clubId'] as String? ?? '',
      projectId: map['projectId'] as String? ?? 'general',
      status: map['status'] as String? ?? 'todo',
      title: map['title'] as String? ?? '',
      dueLabel: map['dueLabel'] as String? ?? '',
      estimateMinutes: map['estimateMinutes'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}
