import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'classroom_model.freezed.dart';
part 'classroom_model.g.dart';

// Bộ chuyển đổi Timestamp sang DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}

@freezed
class ClassroomModel with _$ClassroomModel {
  const factory ClassroomModel({
    required String id,
    required String name,
    required String subject,
    required String teacherId,
    required String teacherName,
    @TimestampConverter() required DateTime createdAt,
    required List<String> students,
  }) = _ClassroomModel;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) =>
      _$ClassroomModelFromJson(json);
}