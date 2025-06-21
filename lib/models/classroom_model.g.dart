// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomModelImpl _$$ClassroomModelImplFromJson(Map<String, dynamic> json) =>
    _$ClassroomModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      students:
          (json['students'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$ClassroomModelImplToJson(
        _$ClassroomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subject': instance.subject,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'students': instance.students,
    };
