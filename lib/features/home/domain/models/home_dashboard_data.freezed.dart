// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeDashboardData _$HomeDashboardDataFromJson(Map<String, dynamic> json) {
  return _HomeDashboardData.fromJson(json);
}

/// @nodoc
mixin _$HomeDashboardData {
  UserModel get user => throw _privateConstructorUsedError;
  List<StudyProgress> get subjectProgress => throw _privateConstructorUsedError;
  ExplorerStats get stats => throw _privateConstructorUsedError;
  List<StudySession> get recentSessions => throw _privateConstructorUsedError;
  bool get hasActiveSession => throw _privateConstructorUsedError;
  DateTime get lastRefreshed => throw _privateConstructorUsedError;

  /// Serializes this HomeDashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeDashboardDataCopyWith<HomeDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeDashboardDataCopyWith<$Res> {
  factory $HomeDashboardDataCopyWith(
          HomeDashboardData value, $Res Function(HomeDashboardData) then) =
      _$HomeDashboardDataCopyWithImpl<$Res, HomeDashboardData>;
  @useResult
  $Res call(
      {UserModel user,
      List<StudyProgress> subjectProgress,
      ExplorerStats stats,
      List<StudySession> recentSessions,
      bool hasActiveSession,
      DateTime lastRefreshed});

  $UserModelCopyWith<$Res> get user;
  $ExplorerStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$HomeDashboardDataCopyWithImpl<$Res, $Val extends HomeDashboardData>
    implements $HomeDashboardDataCopyWith<$Res> {
  _$HomeDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? subjectProgress = null,
    Object? stats = null,
    Object? recentSessions = null,
    Object? hasActiveSession = null,
    Object? lastRefreshed = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      subjectProgress: null == subjectProgress
          ? _value.subjectProgress
          : subjectProgress // ignore: cast_nullable_to_non_nullable
              as List<StudyProgress>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ExplorerStats,
      recentSessions: null == recentSessions
          ? _value.recentSessions
          : recentSessions // ignore: cast_nullable_to_non_nullable
              as List<StudySession>,
      hasActiveSession: null == hasActiveSession
          ? _value.hasActiveSession
          : hasActiveSession // ignore: cast_nullable_to_non_nullable
              as bool,
      lastRefreshed: null == lastRefreshed
          ? _value.lastRefreshed
          : lastRefreshed // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExplorerStatsCopyWith<$Res> get stats {
    return $ExplorerStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeDashboardDataImplCopyWith<$Res>
    implements $HomeDashboardDataCopyWith<$Res> {
  factory _$$HomeDashboardDataImplCopyWith(_$HomeDashboardDataImpl value,
          $Res Function(_$HomeDashboardDataImpl) then) =
      __$$HomeDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserModel user,
      List<StudyProgress> subjectProgress,
      ExplorerStats stats,
      List<StudySession> recentSessions,
      bool hasActiveSession,
      DateTime lastRefreshed});

  @override
  $UserModelCopyWith<$Res> get user;
  @override
  $ExplorerStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$HomeDashboardDataImplCopyWithImpl<$Res>
    extends _$HomeDashboardDataCopyWithImpl<$Res, _$HomeDashboardDataImpl>
    implements _$$HomeDashboardDataImplCopyWith<$Res> {
  __$$HomeDashboardDataImplCopyWithImpl(_$HomeDashboardDataImpl _value,
      $Res Function(_$HomeDashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? subjectProgress = null,
    Object? stats = null,
    Object? recentSessions = null,
    Object? hasActiveSession = null,
    Object? lastRefreshed = null,
  }) {
    return _then(_$HomeDashboardDataImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      subjectProgress: null == subjectProgress
          ? _value._subjectProgress
          : subjectProgress // ignore: cast_nullable_to_non_nullable
              as List<StudyProgress>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ExplorerStats,
      recentSessions: null == recentSessions
          ? _value._recentSessions
          : recentSessions // ignore: cast_nullable_to_non_nullable
              as List<StudySession>,
      hasActiveSession: null == hasActiveSession
          ? _value.hasActiveSession
          : hasActiveSession // ignore: cast_nullable_to_non_nullable
              as bool,
      lastRefreshed: null == lastRefreshed
          ? _value.lastRefreshed
          : lastRefreshed // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeDashboardDataImpl implements _HomeDashboardData {
  const _$HomeDashboardDataImpl(
      {required this.user,
      required final List<StudyProgress> subjectProgress,
      required this.stats,
      required final List<StudySession> recentSessions,
      required this.hasActiveSession,
      required this.lastRefreshed})
      : _subjectProgress = subjectProgress,
        _recentSessions = recentSessions;

  factory _$HomeDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeDashboardDataImplFromJson(json);

  @override
  final UserModel user;
  final List<StudyProgress> _subjectProgress;
  @override
  List<StudyProgress> get subjectProgress {
    if (_subjectProgress is EqualUnmodifiableListView) return _subjectProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjectProgress);
  }

  @override
  final ExplorerStats stats;
  final List<StudySession> _recentSessions;
  @override
  List<StudySession> get recentSessions {
    if (_recentSessions is EqualUnmodifiableListView) return _recentSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentSessions);
  }

  @override
  final bool hasActiveSession;
  @override
  final DateTime lastRefreshed;

  @override
  String toString() {
    return 'HomeDashboardData(user: $user, subjectProgress: $subjectProgress, stats: $stats, recentSessions: $recentSessions, hasActiveSession: $hasActiveSession, lastRefreshed: $lastRefreshed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeDashboardDataImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other._subjectProgress, _subjectProgress) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality()
                .equals(other._recentSessions, _recentSessions) &&
            (identical(other.hasActiveSession, hasActiveSession) ||
                other.hasActiveSession == hasActiveSession) &&
            (identical(other.lastRefreshed, lastRefreshed) ||
                other.lastRefreshed == lastRefreshed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(_subjectProgress),
      stats,
      const DeepCollectionEquality().hash(_recentSessions),
      hasActiveSession,
      lastRefreshed);

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeDashboardDataImplCopyWith<_$HomeDashboardDataImpl> get copyWith =>
      __$$HomeDashboardDataImplCopyWithImpl<_$HomeDashboardDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeDashboardDataImplToJson(
      this,
    );
  }
}

abstract class _HomeDashboardData implements HomeDashboardData {
  const factory _HomeDashboardData(
      {required final UserModel user,
      required final List<StudyProgress> subjectProgress,
      required final ExplorerStats stats,
      required final List<StudySession> recentSessions,
      required final bool hasActiveSession,
      required final DateTime lastRefreshed}) = _$HomeDashboardDataImpl;

  factory _HomeDashboardData.fromJson(Map<String, dynamic> json) =
      _$HomeDashboardDataImpl.fromJson;

  @override
  UserModel get user;
  @override
  List<StudyProgress> get subjectProgress;
  @override
  ExplorerStats get stats;
  @override
  List<StudySession> get recentSessions;
  @override
  bool get hasActiveSession;
  @override
  DateTime get lastRefreshed;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeDashboardDataImplCopyWith<_$HomeDashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
