import 'dart:convert';

class AppSettings {
  final double dailyStudyTarget;

  AppSettings({this.dailyStudyTarget = 1.0}); // Default to 1 hour

  AppSettings copyWith({double? dailyStudyTarget}) {
    return AppSettings(
      dailyStudyTarget: dailyStudyTarget ?? this.dailyStudyTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {'dailyStudyTarget': dailyStudyTarget};
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyStudyTarget: (json['dailyStudyTarget'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  String toString() => 'AppSettings(dailyStudyTarget: $dailyStudyTarget)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings && other.dailyStudyTarget == dailyStudyTarget;
  }

  @override
  int get hashCode => dailyStudyTarget.hashCode;
}
