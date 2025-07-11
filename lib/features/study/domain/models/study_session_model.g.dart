// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 1;

  @override
  StudySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySession(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudySessionImpl _$$StudySessionImplFromJson(Map<String, dynamic> json) =>
    _$StudySessionImpl(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$$StudySessionImplToJson(_$StudySessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'notes': instance.notes,
    };
