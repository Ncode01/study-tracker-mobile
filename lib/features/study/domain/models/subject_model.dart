import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'subject_model.freezed.dart';
part 'subject_model.g.dart';

/// Subject domain model with Hive persistence
@freezed
@HiveType(typeId: 0)
class Subject with _$Subject {
  const factory Subject({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
}
