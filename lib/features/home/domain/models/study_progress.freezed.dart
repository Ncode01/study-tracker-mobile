// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyProgress _$StudyProgressFromJson(Map<String, dynamic> json) {
  return _StudyProgress.fromJson(json);
}

/// @nodoc
mixin _$StudyProgress {
  Subject get subject => throw _privateConstructorUsedError;
  Duration get weeklyTime => throw _privateConstructorUsedError;
  Duration get targetTime => throw _privateConstructorUsedError;
  int get sessionsThisWeek => throw _privateConstructorUsedError;
  DateTime get lastStudied => throw _privateConstructorUsedError;
  double get completionPercentage => throw _privateConstructorUsedError;
  String get nextSuggestedTopic => throw _privateConstructorUsedError;
  String get continentEmoji => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;

  /// Serializes this StudyProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyProgressCopyWith<StudyProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyProgressCopyWith<$Res> {
  factory $StudyProgressCopyWith(
          StudyProgress value, $Res Function(StudyProgress) then) =
      _$StudyProgressCopyWithImpl<$Res, StudyProgress>;
  @useResult
  $Res call(
      {Subject subject,
      Duration weeklyTime,
      Duration targetTime,
      int sessionsThisWeek,
      DateTime lastStudied,
      double completionPercentage,
      String nextSuggestedTopic,
      String continentEmoji,
      int level,
      int xpEarned});

  $SubjectCopyWith<$Res> get subject;
}

/// @nodoc
class _$StudyProgressCopyWithImpl<$Res, $Val extends StudyProgress>
    implements $StudyProgressCopyWith<$Res> {
  _$StudyProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? weeklyTime = null,
    Object? targetTime = null,
    Object? sessionsThisWeek = null,
    Object? lastStudied = null,
    Object? completionPercentage = null,
    Object? nextSuggestedTopic = null,
    Object? continentEmoji = null,
    Object? level = null,
    Object? xpEarned = null,
  }) {
    return _then(_value.copyWith(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as Subject,
      weeklyTime: null == weeklyTime
          ? _value.weeklyTime
          : weeklyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      targetTime: null == targetTime
          ? _value.targetTime
          : targetTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsThisWeek: null == sessionsThisWeek
          ? _value.sessionsThisWeek
          : sessionsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudied: null == lastStudied
          ? _value.lastStudied
          : lastStudied // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      nextSuggestedTopic: null == nextSuggestedTopic
          ? _value.nextSuggestedTopic
          : nextSuggestedTopic // ignore: cast_nullable_to_non_nullable
              as String,
      continentEmoji: null == continentEmoji
          ? _value.continentEmoji
          : continentEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubjectCopyWith<$Res> get subject {
    return $SubjectCopyWith<$Res>(_value.subject, (value) {
      return _then(_value.copyWith(subject: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudyProgressImplCopyWith<$Res>
    implements $StudyProgressCopyWith<$Res> {
  factory _$$StudyProgressImplCopyWith(
          _$StudyProgressImpl value, $Res Function(_$StudyProgressImpl) then) =
      __$$StudyProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Subject subject,
      Duration weeklyTime,
      Duration targetTime,
      int sessionsThisWeek,
      DateTime lastStudied,
      double completionPercentage,
      String nextSuggestedTopic,
      String continentEmoji,
      int level,
      int xpEarned});

  @override
  $SubjectCopyWith<$Res> get subject;
}

/// @nodoc
class __$$StudyProgressImplCopyWithImpl<$Res>
    extends _$StudyProgressCopyWithImpl<$Res, _$StudyProgressImpl>
    implements _$$StudyProgressImplCopyWith<$Res> {
  __$$StudyProgressImplCopyWithImpl(
      _$StudyProgressImpl _value, $Res Function(_$StudyProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? weeklyTime = null,
    Object? targetTime = null,
    Object? sessionsThisWeek = null,
    Object? lastStudied = null,
    Object? completionPercentage = null,
    Object? nextSuggestedTopic = null,
    Object? continentEmoji = null,
    Object? level = null,
    Object? xpEarned = null,
  }) {
    return _then(_$StudyProgressImpl(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as Subject,
      weeklyTime: null == weeklyTime
          ? _value.weeklyTime
          : weeklyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      targetTime: null == targetTime
          ? _value.targetTime
          : targetTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsThisWeek: null == sessionsThisWeek
          ? _value.sessionsThisWeek
          : sessionsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudied: null == lastStudied
          ? _value.lastStudied
          : lastStudied // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      nextSuggestedTopic: null == nextSuggestedTopic
          ? _value.nextSuggestedTopic
          : nextSuggestedTopic // ignore: cast_nullable_to_non_nullable
              as String,
      continentEmoji: null == continentEmoji
          ? _value.continentEmoji
          : continentEmoji // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyProgressImpl implements _StudyProgress {
  const _$StudyProgressImpl(
      {required this.subject,
      required this.weeklyTime,
      required this.targetTime,
      required this.sessionsThisWeek,
      required this.lastStudied,
      required this.completionPercentage,
      required this.nextSuggestedTopic,
      required this.continentEmoji,
      required this.level,
      required this.xpEarned});

  factory _$StudyProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyProgressImplFromJson(json);

  @override
  final Subject subject;
  @override
  final Duration weeklyTime;
  @override
  final Duration targetTime;
  @override
  final int sessionsThisWeek;
  @override
  final DateTime lastStudied;
  @override
  final double completionPercentage;
  @override
  final String nextSuggestedTopic;
  @override
  final String continentEmoji;
  @override
  final int level;
  @override
  final int xpEarned;

  @override
  String toString() {
    return 'StudyProgress(subject: $subject, weeklyTime: $weeklyTime, targetTime: $targetTime, sessionsThisWeek: $sessionsThisWeek, lastStudied: $lastStudied, completionPercentage: $completionPercentage, nextSuggestedTopic: $nextSuggestedTopic, continentEmoji: $continentEmoji, level: $level, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyProgressImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.weeklyTime, weeklyTime) ||
                other.weeklyTime == weeklyTime) &&
            (identical(other.targetTime, targetTime) ||
                other.targetTime == targetTime) &&
            (identical(other.sessionsThisWeek, sessionsThisWeek) ||
                other.sessionsThisWeek == sessionsThisWeek) &&
            (identical(other.lastStudied, lastStudied) ||
                other.lastStudied == lastStudied) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.nextSuggestedTopic, nextSuggestedTopic) ||
                other.nextSuggestedTopic == nextSuggestedTopic) &&
            (identical(other.continentEmoji, continentEmoji) ||
                other.continentEmoji == continentEmoji) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      subject,
      weeklyTime,
      targetTime,
      sessionsThisWeek,
      lastStudied,
      completionPercentage,
      nextSuggestedTopic,
      continentEmoji,
      level,
      xpEarned);

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyProgressImplCopyWith<_$StudyProgressImpl> get copyWith =>
      __$$StudyProgressImplCopyWithImpl<_$StudyProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyProgressImplToJson(
      this,
    );
  }
}

abstract class _StudyProgress implements StudyProgress {
  const factory _StudyProgress(
      {required final Subject subject,
      required final Duration weeklyTime,
      required final Duration targetTime,
      required final int sessionsThisWeek,
      required final DateTime lastStudied,
      required final double completionPercentage,
      required final String nextSuggestedTopic,
      required final String continentEmoji,
      required final int level,
      required final int xpEarned}) = _$StudyProgressImpl;

  factory _StudyProgress.fromJson(Map<String, dynamic> json) =
      _$StudyProgressImpl.fromJson;

  @override
  Subject get subject;
  @override
  Duration get weeklyTime;
  @override
  Duration get targetTime;
  @override
  int get sessionsThisWeek;
  @override
  DateTime get lastStudied;
  @override
  double get completionPercentage;
  @override
  String get nextSuggestedTopic;
  @override
  String get continentEmoji;
  @override
  int get level;
  @override
  int get xpEarned;

  /// Create a copy of StudyProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyProgressImplCopyWith<_$StudyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
