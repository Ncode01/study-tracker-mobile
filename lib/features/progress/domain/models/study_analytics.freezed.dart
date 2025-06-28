// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyAnalytics _$StudyAnalyticsFromJson(Map<String, dynamic> json) {
  return _StudyAnalytics.fromJson(json);
}

/// @nodoc
mixin _$StudyAnalytics {
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  Duration get totalStudyTime => throw _privateConstructorUsedError;
  List<DailyStudyData> get dailyData => throw _privateConstructorUsedError;
  List<SubjectAnalytics> get subjectBreakdown =>
      throw _privateConstructorUsedError;
  StudyInsights get insights => throw _privateConstructorUsedError;
  List<Achievement> get achievements => throw _privateConstructorUsedError;

  /// Serializes this StudyAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyAnalyticsCopyWith<StudyAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyAnalyticsCopyWith<$Res> {
  factory $StudyAnalyticsCopyWith(
          StudyAnalytics value, $Res Function(StudyAnalytics) then) =
      _$StudyAnalyticsCopyWithImpl<$Res, StudyAnalytics>;
  @useResult
  $Res call(
      {DateTime periodStart,
      DateTime periodEnd,
      Duration totalStudyTime,
      List<DailyStudyData> dailyData,
      List<SubjectAnalytics> subjectBreakdown,
      StudyInsights insights,
      List<Achievement> achievements});

  $StudyInsightsCopyWith<$Res> get insights;
}

/// @nodoc
class _$StudyAnalyticsCopyWithImpl<$Res, $Val extends StudyAnalytics>
    implements $StudyAnalyticsCopyWith<$Res> {
  _$StudyAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalStudyTime = null,
    Object? dailyData = null,
    Object? subjectBreakdown = null,
    Object? insights = null,
    Object? achievements = null,
  }) {
    return _then(_value.copyWith(
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalStudyTime: null == totalStudyTime
          ? _value.totalStudyTime
          : totalStudyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      dailyData: null == dailyData
          ? _value.dailyData
          : dailyData // ignore: cast_nullable_to_non_nullable
              as List<DailyStudyData>,
      subjectBreakdown: null == subjectBreakdown
          ? _value.subjectBreakdown
          : subjectBreakdown // ignore: cast_nullable_to_non_nullable
              as List<SubjectAnalytics>,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as StudyInsights,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
    ) as $Val);
  }

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudyInsightsCopyWith<$Res> get insights {
    return $StudyInsightsCopyWith<$Res>(_value.insights, (value) {
      return _then(_value.copyWith(insights: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudyAnalyticsImplCopyWith<$Res>
    implements $StudyAnalyticsCopyWith<$Res> {
  factory _$$StudyAnalyticsImplCopyWith(_$StudyAnalyticsImpl value,
          $Res Function(_$StudyAnalyticsImpl) then) =
      __$$StudyAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime periodStart,
      DateTime periodEnd,
      Duration totalStudyTime,
      List<DailyStudyData> dailyData,
      List<SubjectAnalytics> subjectBreakdown,
      StudyInsights insights,
      List<Achievement> achievements});

  @override
  $StudyInsightsCopyWith<$Res> get insights;
}

/// @nodoc
class __$$StudyAnalyticsImplCopyWithImpl<$Res>
    extends _$StudyAnalyticsCopyWithImpl<$Res, _$StudyAnalyticsImpl>
    implements _$$StudyAnalyticsImplCopyWith<$Res> {
  __$$StudyAnalyticsImplCopyWithImpl(
      _$StudyAnalyticsImpl _value, $Res Function(_$StudyAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalStudyTime = null,
    Object? dailyData = null,
    Object? subjectBreakdown = null,
    Object? insights = null,
    Object? achievements = null,
  }) {
    return _then(_$StudyAnalyticsImpl(
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalStudyTime: null == totalStudyTime
          ? _value.totalStudyTime
          : totalStudyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      dailyData: null == dailyData
          ? _value._dailyData
          : dailyData // ignore: cast_nullable_to_non_nullable
              as List<DailyStudyData>,
      subjectBreakdown: null == subjectBreakdown
          ? _value._subjectBreakdown
          : subjectBreakdown // ignore: cast_nullable_to_non_nullable
              as List<SubjectAnalytics>,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as StudyInsights,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyAnalyticsImpl implements _StudyAnalytics {
  const _$StudyAnalyticsImpl(
      {required this.periodStart,
      required this.periodEnd,
      required this.totalStudyTime,
      required final List<DailyStudyData> dailyData,
      required final List<SubjectAnalytics> subjectBreakdown,
      required this.insights,
      required final List<Achievement> achievements})
      : _dailyData = dailyData,
        _subjectBreakdown = subjectBreakdown,
        _achievements = achievements;

  factory _$StudyAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyAnalyticsImplFromJson(json);

  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  final Duration totalStudyTime;
  final List<DailyStudyData> _dailyData;
  @override
  List<DailyStudyData> get dailyData {
    if (_dailyData is EqualUnmodifiableListView) return _dailyData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyData);
  }

  final List<SubjectAnalytics> _subjectBreakdown;
  @override
  List<SubjectAnalytics> get subjectBreakdown {
    if (_subjectBreakdown is EqualUnmodifiableListView)
      return _subjectBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectBreakdown);
  }

  @override
  final StudyInsights insights;
  final List<Achievement> _achievements;
  @override
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  @override
  String toString() {
    return 'StudyAnalytics(periodStart: $periodStart, periodEnd: $periodEnd, totalStudyTime: $totalStudyTime, dailyData: $dailyData, subjectBreakdown: $subjectBreakdown, insights: $insights, achievements: $achievements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyAnalyticsImpl &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.totalStudyTime, totalStudyTime) ||
                other.totalStudyTime == totalStudyTime) &&
            const DeepCollectionEquality()
                .equals(other._dailyData, _dailyData) &&
            const DeepCollectionEquality()
                .equals(other._subjectBreakdown, _subjectBreakdown) &&
            (identical(other.insights, insights) ||
                other.insights == insights) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      periodStart,
      periodEnd,
      totalStudyTime,
      const DeepCollectionEquality().hash(_dailyData),
      const DeepCollectionEquality().hash(_subjectBreakdown),
      insights,
      const DeepCollectionEquality().hash(_achievements));

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyAnalyticsImplCopyWith<_$StudyAnalyticsImpl> get copyWith =>
      __$$StudyAnalyticsImplCopyWithImpl<_$StudyAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _StudyAnalytics implements StudyAnalytics {
  const factory _StudyAnalytics(
      {required final DateTime periodStart,
      required final DateTime periodEnd,
      required final Duration totalStudyTime,
      required final List<DailyStudyData> dailyData,
      required final List<SubjectAnalytics> subjectBreakdown,
      required final StudyInsights insights,
      required final List<Achievement> achievements}) = _$StudyAnalyticsImpl;

  factory _StudyAnalytics.fromJson(Map<String, dynamic> json) =
      _$StudyAnalyticsImpl.fromJson;

  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  Duration get totalStudyTime;
  @override
  List<DailyStudyData> get dailyData;
  @override
  List<SubjectAnalytics> get subjectBreakdown;
  @override
  StudyInsights get insights;
  @override
  List<Achievement> get achievements;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyAnalyticsImplCopyWith<_$StudyAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyStudyData _$DailyStudyDataFromJson(Map<String, dynamic> json) {
  return _DailyStudyData.fromJson(json);
}

/// @nodoc
mixin _$DailyStudyData {
  DateTime get date => throw _privateConstructorUsedError;
  Duration get studyTime => throw _privateConstructorUsedError;
  int get sessionsCompleted => throw _privateConstructorUsedError;
  Map<String, Duration> get subjectBreakdown =>
      throw _privateConstructorUsedError;

  /// Serializes this DailyStudyData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStudyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStudyDataCopyWith<DailyStudyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStudyDataCopyWith<$Res> {
  factory $DailyStudyDataCopyWith(
          DailyStudyData value, $Res Function(DailyStudyData) then) =
      _$DailyStudyDataCopyWithImpl<$Res, DailyStudyData>;
  @useResult
  $Res call(
      {DateTime date,
      Duration studyTime,
      int sessionsCompleted,
      Map<String, Duration> subjectBreakdown});
}

/// @nodoc
class _$DailyStudyDataCopyWithImpl<$Res, $Val extends DailyStudyData>
    implements $DailyStudyDataCopyWith<$Res> {
  _$DailyStudyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStudyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? studyTime = null,
    Object? sessionsCompleted = null,
    Object? subjectBreakdown = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      studyTime: null == studyTime
          ? _value.studyTime
          : studyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsCompleted: null == sessionsCompleted
          ? _value.sessionsCompleted
          : sessionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      subjectBreakdown: null == subjectBreakdown
          ? _value.subjectBreakdown
          : subjectBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStudyDataImplCopyWith<$Res>
    implements $DailyStudyDataCopyWith<$Res> {
  factory _$$DailyStudyDataImplCopyWith(_$DailyStudyDataImpl value,
          $Res Function(_$DailyStudyDataImpl) then) =
      __$$DailyStudyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      Duration studyTime,
      int sessionsCompleted,
      Map<String, Duration> subjectBreakdown});
}

/// @nodoc
class __$$DailyStudyDataImplCopyWithImpl<$Res>
    extends _$DailyStudyDataCopyWithImpl<$Res, _$DailyStudyDataImpl>
    implements _$$DailyStudyDataImplCopyWith<$Res> {
  __$$DailyStudyDataImplCopyWithImpl(
      _$DailyStudyDataImpl _value, $Res Function(_$DailyStudyDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyStudyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? studyTime = null,
    Object? sessionsCompleted = null,
    Object? subjectBreakdown = null,
  }) {
    return _then(_$DailyStudyDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      studyTime: null == studyTime
          ? _value.studyTime
          : studyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsCompleted: null == sessionsCompleted
          ? _value.sessionsCompleted
          : sessionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      subjectBreakdown: null == subjectBreakdown
          ? _value._subjectBreakdown
          : subjectBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStudyDataImpl implements _DailyStudyData {
  const _$DailyStudyDataImpl(
      {required this.date,
      required this.studyTime,
      required this.sessionsCompleted,
      required final Map<String, Duration> subjectBreakdown})
      : _subjectBreakdown = subjectBreakdown;

  factory _$DailyStudyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStudyDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final Duration studyTime;
  @override
  final int sessionsCompleted;
  final Map<String, Duration> _subjectBreakdown;
  @override
  Map<String, Duration> get subjectBreakdown {
    if (_subjectBreakdown is EqualUnmodifiableMapView) return _subjectBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_subjectBreakdown);
  }

  @override
  String toString() {
    return 'DailyStudyData(date: $date, studyTime: $studyTime, sessionsCompleted: $sessionsCompleted, subjectBreakdown: $subjectBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStudyDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.studyTime, studyTime) ||
                other.studyTime == studyTime) &&
            (identical(other.sessionsCompleted, sessionsCompleted) ||
                other.sessionsCompleted == sessionsCompleted) &&
            const DeepCollectionEquality()
                .equals(other._subjectBreakdown, _subjectBreakdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      studyTime,
      sessionsCompleted,
      const DeepCollectionEquality().hash(_subjectBreakdown));

  /// Create a copy of DailyStudyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStudyDataImplCopyWith<_$DailyStudyDataImpl> get copyWith =>
      __$$DailyStudyDataImplCopyWithImpl<_$DailyStudyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStudyDataImplToJson(
      this,
    );
  }
}

abstract class _DailyStudyData implements DailyStudyData {
  const factory _DailyStudyData(
          {required final DateTime date,
          required final Duration studyTime,
          required final int sessionsCompleted,
          required final Map<String, Duration> subjectBreakdown}) =
      _$DailyStudyDataImpl;

  factory _DailyStudyData.fromJson(Map<String, dynamic> json) =
      _$DailyStudyDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  Duration get studyTime;
  @override
  int get sessionsCompleted;
  @override
  Map<String, Duration> get subjectBreakdown;

  /// Create a copy of DailyStudyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStudyDataImplCopyWith<_$DailyStudyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubjectAnalytics _$SubjectAnalyticsFromJson(Map<String, dynamic> json) {
  return _SubjectAnalytics.fromJson(json);
}

/// @nodoc
mixin _$SubjectAnalytics {
  String get subjectId => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  Duration get totalTime => throw _privateConstructorUsedError;
  int get sessionsCompleted => throw _privateConstructorUsedError;
  double get averageSessionDuration =>
      throw _privateConstructorUsedError; // in minutes
  DateTime get lastStudied => throw _privateConstructorUsedError;
  StudyTrend get trend => throw _privateConstructorUsedError;

  /// Serializes this SubjectAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectAnalyticsCopyWith<SubjectAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectAnalyticsCopyWith<$Res> {
  factory $SubjectAnalyticsCopyWith(
          SubjectAnalytics value, $Res Function(SubjectAnalytics) then) =
      _$SubjectAnalyticsCopyWithImpl<$Res, SubjectAnalytics>;
  @useResult
  $Res call(
      {String subjectId,
      String subjectName,
      Duration totalTime,
      int sessionsCompleted,
      double averageSessionDuration,
      DateTime lastStudied,
      StudyTrend trend});
}

/// @nodoc
class _$SubjectAnalyticsCopyWithImpl<$Res, $Val extends SubjectAnalytics>
    implements $SubjectAnalyticsCopyWith<$Res> {
  _$SubjectAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectId = null,
    Object? subjectName = null,
    Object? totalTime = null,
    Object? sessionsCompleted = null,
    Object? averageSessionDuration = null,
    Object? lastStudied = null,
    Object? trend = null,
  }) {
    return _then(_value.copyWith(
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectName: null == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String,
      totalTime: null == totalTime
          ? _value.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsCompleted: null == sessionsCompleted
          ? _value.sessionsCompleted
          : sessionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageSessionDuration: null == averageSessionDuration
          ? _value.averageSessionDuration
          : averageSessionDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastStudied: null == lastStudied
          ? _value.lastStudied
          : lastStudied // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as StudyTrend,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubjectAnalyticsImplCopyWith<$Res>
    implements $SubjectAnalyticsCopyWith<$Res> {
  factory _$$SubjectAnalyticsImplCopyWith(_$SubjectAnalyticsImpl value,
          $Res Function(_$SubjectAnalyticsImpl) then) =
      __$$SubjectAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String subjectId,
      String subjectName,
      Duration totalTime,
      int sessionsCompleted,
      double averageSessionDuration,
      DateTime lastStudied,
      StudyTrend trend});
}

/// @nodoc
class __$$SubjectAnalyticsImplCopyWithImpl<$Res>
    extends _$SubjectAnalyticsCopyWithImpl<$Res, _$SubjectAnalyticsImpl>
    implements _$$SubjectAnalyticsImplCopyWith<$Res> {
  __$$SubjectAnalyticsImplCopyWithImpl(_$SubjectAnalyticsImpl _value,
      $Res Function(_$SubjectAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubjectAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectId = null,
    Object? subjectName = null,
    Object? totalTime = null,
    Object? sessionsCompleted = null,
    Object? averageSessionDuration = null,
    Object? lastStudied = null,
    Object? trend = null,
  }) {
    return _then(_$SubjectAnalyticsImpl(
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectName: null == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String,
      totalTime: null == totalTime
          ? _value.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      sessionsCompleted: null == sessionsCompleted
          ? _value.sessionsCompleted
          : sessionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageSessionDuration: null == averageSessionDuration
          ? _value.averageSessionDuration
          : averageSessionDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastStudied: null == lastStudied
          ? _value.lastStudied
          : lastStudied // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as StudyTrend,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectAnalyticsImpl implements _SubjectAnalytics {
  const _$SubjectAnalyticsImpl(
      {required this.subjectId,
      required this.subjectName,
      required this.totalTime,
      required this.sessionsCompleted,
      required this.averageSessionDuration,
      required this.lastStudied,
      required this.trend});

  factory _$SubjectAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectAnalyticsImplFromJson(json);

  @override
  final String subjectId;
  @override
  final String subjectName;
  @override
  final Duration totalTime;
  @override
  final int sessionsCompleted;
  @override
  final double averageSessionDuration;
// in minutes
  @override
  final DateTime lastStudied;
  @override
  final StudyTrend trend;

  @override
  String toString() {
    return 'SubjectAnalytics(subjectId: $subjectId, subjectName: $subjectName, totalTime: $totalTime, sessionsCompleted: $sessionsCompleted, averageSessionDuration: $averageSessionDuration, lastStudied: $lastStudied, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectAnalyticsImpl &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.sessionsCompleted, sessionsCompleted) ||
                other.sessionsCompleted == sessionsCompleted) &&
            (identical(other.averageSessionDuration, averageSessionDuration) ||
                other.averageSessionDuration == averageSessionDuration) &&
            (identical(other.lastStudied, lastStudied) ||
                other.lastStudied == lastStudied) &&
            (identical(other.trend, trend) || other.trend == trend));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subjectId, subjectName,
      totalTime, sessionsCompleted, averageSessionDuration, lastStudied, trend);

  /// Create a copy of SubjectAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectAnalyticsImplCopyWith<_$SubjectAnalyticsImpl> get copyWith =>
      __$$SubjectAnalyticsImplCopyWithImpl<_$SubjectAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _SubjectAnalytics implements SubjectAnalytics {
  const factory _SubjectAnalytics(
      {required final String subjectId,
      required final String subjectName,
      required final Duration totalTime,
      required final int sessionsCompleted,
      required final double averageSessionDuration,
      required final DateTime lastStudied,
      required final StudyTrend trend}) = _$SubjectAnalyticsImpl;

  factory _SubjectAnalytics.fromJson(Map<String, dynamic> json) =
      _$SubjectAnalyticsImpl.fromJson;

  @override
  String get subjectId;
  @override
  String get subjectName;
  @override
  Duration get totalTime;
  @override
  int get sessionsCompleted;
  @override
  double get averageSessionDuration; // in minutes
  @override
  DateTime get lastStudied;
  @override
  StudyTrend get trend;

  /// Create a copy of SubjectAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectAnalyticsImplCopyWith<_$SubjectAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyInsights _$StudyInsightsFromJson(Map<String, dynamic> json) {
  return _StudyInsights.fromJson(json);
}

/// @nodoc
mixin _$StudyInsights {
  StudyStreak get currentStreak => throw _privateConstructorUsedError;
  StudyStreak get longestStreak => throw _privateConstructorUsedError;
  TimeOfDay get mostProductiveTime => throw _privateConstructorUsedError;
  DayOfWeek get mostProductiveDay => throw _privateConstructorUsedError;
  double get weeklyGoalProgress =>
      throw _privateConstructorUsedError; // 0.0 to 1.0
  Duration get averageDailyStudyTime => throw _privateConstructorUsedError;
  List<String> get recommendedSubjects => throw _privateConstructorUsedError;

  /// Serializes this StudyInsights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyInsightsCopyWith<StudyInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyInsightsCopyWith<$Res> {
  factory $StudyInsightsCopyWith(
          StudyInsights value, $Res Function(StudyInsights) then) =
      _$StudyInsightsCopyWithImpl<$Res, StudyInsights>;
  @useResult
  $Res call(
      {StudyStreak currentStreak,
      StudyStreak longestStreak,
      TimeOfDay mostProductiveTime,
      DayOfWeek mostProductiveDay,
      double weeklyGoalProgress,
      Duration averageDailyStudyTime,
      List<String> recommendedSubjects});

  $StudyStreakCopyWith<$Res> get currentStreak;
  $StudyStreakCopyWith<$Res> get longestStreak;
  $TimeOfDayCopyWith<$Res> get mostProductiveTime;
}

/// @nodoc
class _$StudyInsightsCopyWithImpl<$Res, $Val extends StudyInsights>
    implements $StudyInsightsCopyWith<$Res> {
  _$StudyInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? mostProductiveTime = null,
    Object? mostProductiveDay = null,
    Object? weeklyGoalProgress = null,
    Object? averageDailyStudyTime = null,
    Object? recommendedSubjects = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as StudyStreak,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as StudyStreak,
      mostProductiveTime: null == mostProductiveTime
          ? _value.mostProductiveTime
          : mostProductiveTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      mostProductiveDay: null == mostProductiveDay
          ? _value.mostProductiveDay
          : mostProductiveDay // ignore: cast_nullable_to_non_nullable
              as DayOfWeek,
      weeklyGoalProgress: null == weeklyGoalProgress
          ? _value.weeklyGoalProgress
          : weeklyGoalProgress // ignore: cast_nullable_to_non_nullable
              as double,
      averageDailyStudyTime: null == averageDailyStudyTime
          ? _value.averageDailyStudyTime
          : averageDailyStudyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      recommendedSubjects: null == recommendedSubjects
          ? _value.recommendedSubjects
          : recommendedSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudyStreakCopyWith<$Res> get currentStreak {
    return $StudyStreakCopyWith<$Res>(_value.currentStreak, (value) {
      return _then(_value.copyWith(currentStreak: value) as $Val);
    });
  }

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudyStreakCopyWith<$Res> get longestStreak {
    return $StudyStreakCopyWith<$Res>(_value.longestStreak, (value) {
      return _then(_value.copyWith(longestStreak: value) as $Val);
    });
  }

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get mostProductiveTime {
    return $TimeOfDayCopyWith<$Res>(_value.mostProductiveTime, (value) {
      return _then(_value.copyWith(mostProductiveTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudyInsightsImplCopyWith<$Res>
    implements $StudyInsightsCopyWith<$Res> {
  factory _$$StudyInsightsImplCopyWith(
          _$StudyInsightsImpl value, $Res Function(_$StudyInsightsImpl) then) =
      __$$StudyInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StudyStreak currentStreak,
      StudyStreak longestStreak,
      TimeOfDay mostProductiveTime,
      DayOfWeek mostProductiveDay,
      double weeklyGoalProgress,
      Duration averageDailyStudyTime,
      List<String> recommendedSubjects});

  @override
  $StudyStreakCopyWith<$Res> get currentStreak;
  @override
  $StudyStreakCopyWith<$Res> get longestStreak;
  @override
  $TimeOfDayCopyWith<$Res> get mostProductiveTime;
}

/// @nodoc
class __$$StudyInsightsImplCopyWithImpl<$Res>
    extends _$StudyInsightsCopyWithImpl<$Res, _$StudyInsightsImpl>
    implements _$$StudyInsightsImplCopyWith<$Res> {
  __$$StudyInsightsImplCopyWithImpl(
      _$StudyInsightsImpl _value, $Res Function(_$StudyInsightsImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? mostProductiveTime = null,
    Object? mostProductiveDay = null,
    Object? weeklyGoalProgress = null,
    Object? averageDailyStudyTime = null,
    Object? recommendedSubjects = null,
  }) {
    return _then(_$StudyInsightsImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as StudyStreak,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as StudyStreak,
      mostProductiveTime: null == mostProductiveTime
          ? _value.mostProductiveTime
          : mostProductiveTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      mostProductiveDay: null == mostProductiveDay
          ? _value.mostProductiveDay
          : mostProductiveDay // ignore: cast_nullable_to_non_nullable
              as DayOfWeek,
      weeklyGoalProgress: null == weeklyGoalProgress
          ? _value.weeklyGoalProgress
          : weeklyGoalProgress // ignore: cast_nullable_to_non_nullable
              as double,
      averageDailyStudyTime: null == averageDailyStudyTime
          ? _value.averageDailyStudyTime
          : averageDailyStudyTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      recommendedSubjects: null == recommendedSubjects
          ? _value._recommendedSubjects
          : recommendedSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyInsightsImpl implements _StudyInsights {
  const _$StudyInsightsImpl(
      {required this.currentStreak,
      required this.longestStreak,
      required this.mostProductiveTime,
      required this.mostProductiveDay,
      required this.weeklyGoalProgress,
      required this.averageDailyStudyTime,
      required final List<String> recommendedSubjects})
      : _recommendedSubjects = recommendedSubjects;

  factory _$StudyInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyInsightsImplFromJson(json);

  @override
  final StudyStreak currentStreak;
  @override
  final StudyStreak longestStreak;
  @override
  final TimeOfDay mostProductiveTime;
  @override
  final DayOfWeek mostProductiveDay;
  @override
  final double weeklyGoalProgress;
// 0.0 to 1.0
  @override
  final Duration averageDailyStudyTime;
  final List<String> _recommendedSubjects;
  @override
  List<String> get recommendedSubjects {
    if (_recommendedSubjects is EqualUnmodifiableListView)
      return _recommendedSubjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendedSubjects);
  }

  @override
  String toString() {
    return 'StudyInsights(currentStreak: $currentStreak, longestStreak: $longestStreak, mostProductiveTime: $mostProductiveTime, mostProductiveDay: $mostProductiveDay, weeklyGoalProgress: $weeklyGoalProgress, averageDailyStudyTime: $averageDailyStudyTime, recommendedSubjects: $recommendedSubjects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyInsightsImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.mostProductiveTime, mostProductiveTime) ||
                other.mostProductiveTime == mostProductiveTime) &&
            (identical(other.mostProductiveDay, mostProductiveDay) ||
                other.mostProductiveDay == mostProductiveDay) &&
            (identical(other.weeklyGoalProgress, weeklyGoalProgress) ||
                other.weeklyGoalProgress == weeklyGoalProgress) &&
            (identical(other.averageDailyStudyTime, averageDailyStudyTime) ||
                other.averageDailyStudyTime == averageDailyStudyTime) &&
            const DeepCollectionEquality()
                .equals(other._recommendedSubjects, _recommendedSubjects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      longestStreak,
      mostProductiveTime,
      mostProductiveDay,
      weeklyGoalProgress,
      averageDailyStudyTime,
      const DeepCollectionEquality().hash(_recommendedSubjects));

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyInsightsImplCopyWith<_$StudyInsightsImpl> get copyWith =>
      __$$StudyInsightsImplCopyWithImpl<_$StudyInsightsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyInsightsImplToJson(
      this,
    );
  }
}

abstract class _StudyInsights implements StudyInsights {
  const factory _StudyInsights(
      {required final StudyStreak currentStreak,
      required final StudyStreak longestStreak,
      required final TimeOfDay mostProductiveTime,
      required final DayOfWeek mostProductiveDay,
      required final double weeklyGoalProgress,
      required final Duration averageDailyStudyTime,
      required final List<String> recommendedSubjects}) = _$StudyInsightsImpl;

  factory _StudyInsights.fromJson(Map<String, dynamic> json) =
      _$StudyInsightsImpl.fromJson;

  @override
  StudyStreak get currentStreak;
  @override
  StudyStreak get longestStreak;
  @override
  TimeOfDay get mostProductiveTime;
  @override
  DayOfWeek get mostProductiveDay;
  @override
  double get weeklyGoalProgress; // 0.0 to 1.0
  @override
  Duration get averageDailyStudyTime;
  @override
  List<String> get recommendedSubjects;

  /// Create a copy of StudyInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyInsightsImplCopyWith<_$StudyInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyStreak _$StudyStreakFromJson(Map<String, dynamic> json) {
  return _StudyStreak.fromJson(json);
}

/// @nodoc
mixin _$StudyStreak {
  int get days => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this StudyStreak to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyStreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyStreakCopyWith<StudyStreak> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyStreakCopyWith<$Res> {
  factory $StudyStreakCopyWith(
          StudyStreak value, $Res Function(StudyStreak) then) =
      _$StudyStreakCopyWithImpl<$Res, StudyStreak>;
  @useResult
  $Res call({int days, DateTime startDate, DateTime? endDate});
}

/// @nodoc
class _$StudyStreakCopyWithImpl<$Res, $Val extends StudyStreak>
    implements $StudyStreakCopyWith<$Res> {
  _$StudyStreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyStreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? days = null,
    Object? startDate = null,
    Object? endDate = freezed,
  }) {
    return _then(_value.copyWith(
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyStreakImplCopyWith<$Res>
    implements $StudyStreakCopyWith<$Res> {
  factory _$$StudyStreakImplCopyWith(
          _$StudyStreakImpl value, $Res Function(_$StudyStreakImpl) then) =
      __$$StudyStreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int days, DateTime startDate, DateTime? endDate});
}

/// @nodoc
class __$$StudyStreakImplCopyWithImpl<$Res>
    extends _$StudyStreakCopyWithImpl<$Res, _$StudyStreakImpl>
    implements _$$StudyStreakImplCopyWith<$Res> {
  __$$StudyStreakImplCopyWithImpl(
      _$StudyStreakImpl _value, $Res Function(_$StudyStreakImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyStreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? days = null,
    Object? startDate = null,
    Object? endDate = freezed,
  }) {
    return _then(_$StudyStreakImpl(
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyStreakImpl implements _StudyStreak {
  const _$StudyStreakImpl(
      {required this.days, required this.startDate, required this.endDate});

  factory _$StudyStreakImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyStreakImplFromJson(json);

  @override
  final int days;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;

  @override
  String toString() {
    return 'StudyStreak(days: $days, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyStreakImpl &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, days, startDate, endDate);

  /// Create a copy of StudyStreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyStreakImplCopyWith<_$StudyStreakImpl> get copyWith =>
      __$$StudyStreakImplCopyWithImpl<_$StudyStreakImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyStreakImplToJson(
      this,
    );
  }
}

abstract class _StudyStreak implements StudyStreak {
  const factory _StudyStreak(
      {required final int days,
      required final DateTime startDate,
      required final DateTime? endDate}) = _$StudyStreakImpl;

  factory _StudyStreak.fromJson(Map<String, dynamic> json) =
      _$StudyStreakImpl.fromJson;

  @override
  int get days;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;

  /// Create a copy of StudyStreak
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyStreakImplCopyWith<_$StudyStreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) {
  return _TimeOfDay.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDay {
  int get hour => throw _privateConstructorUsedError; // 0-23
  int get minute => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayCopyWith<TimeOfDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayCopyWith<$Res> {
  factory $TimeOfDayCopyWith(TimeOfDay value, $Res Function(TimeOfDay) then) =
      _$TimeOfDayCopyWithImpl<$Res, TimeOfDay>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayCopyWithImpl<$Res, $Val extends TimeOfDay>
    implements $TimeOfDayCopyWith<$Res> {
  _$TimeOfDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeOfDayImplCopyWith<$Res>
    implements $TimeOfDayCopyWith<$Res> {
  factory _$$TimeOfDayImplCopyWith(
          _$TimeOfDayImpl value, $Res Function(_$TimeOfDayImpl) then) =
      __$$TimeOfDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayImplCopyWithImpl<$Res>
    extends _$TimeOfDayCopyWithImpl<$Res, _$TimeOfDayImpl>
    implements _$$TimeOfDayImplCopyWith<$Res> {
  __$$TimeOfDayImplCopyWithImpl(
      _$TimeOfDayImpl _value, $Res Function(_$TimeOfDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeOfDayImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayImpl implements _TimeOfDay {
  const _$TimeOfDayImpl({required this.hour, required this.minute});

  factory _$TimeOfDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayImplFromJson(json);

  @override
  final int hour;
// 0-23
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      __$$TimeOfDayImplCopyWithImpl<_$TimeOfDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDay implements TimeOfDay {
  const factory _TimeOfDay(
      {required final int hour, required final int minute}) = _$TimeOfDayImpl;

  factory _TimeOfDay.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayImpl.fromJson;

  @override
  int get hour; // 0-23
  @override
  int get minute;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  AchievementType get type => throw _privateConstructorUsedError;
  DateTime get unlockedAt => throw _privateConstructorUsedError;
  bool get isNew => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      AchievementType type,
      DateTime unlockedAt,
      bool isNew});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? unlockedAt = null,
    Object? isNew = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      AchievementType type,
      DateTime unlockedAt,
      bool isNew});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? unlockedAt = null,
    Object? isNew = null,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.unlockedAt,
      required this.isNew});

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final AchievementType type;
  @override
  final DateTime unlockedAt;
  @override
  final bool isNew;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, type: $type, unlockedAt: $unlockedAt, isNew: $isNew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.isNew, isNew) || other.isNew == isNew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, type, unlockedAt, isNew);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String id,
      required final String title,
      required final String description,
      required final AchievementType type,
      required final DateTime unlockedAt,
      required final bool isNew}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  AchievementType get type;
  @override
  DateTime get unlockedAt;
  @override
  bool get isNew;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
