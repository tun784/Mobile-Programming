// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassroomModel _$ClassroomModelFromJson(Map<String, dynamic> json) {
  return _ClassroomModel.fromJson(json);
}

/// @nodoc
mixin _$ClassroomModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get teacherName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<String> get students => throw _privateConstructorUsedError;

  /// Serializes this ClassroomModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomModelCopyWith<ClassroomModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomModelCopyWith<$Res> {
  factory $ClassroomModelCopyWith(
          ClassroomModel value, $Res Function(ClassroomModel) then) =
      _$ClassroomModelCopyWithImpl<$Res, ClassroomModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String subject,
      String teacherId,
      String teacherName,
      @TimestampConverter() DateTime createdAt,
      List<String> students});
}

/// @nodoc
class _$ClassroomModelCopyWithImpl<$Res, $Val extends ClassroomModel>
    implements $ClassroomModelCopyWith<$Res> {
  _$ClassroomModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subject = null,
    Object? teacherId = null,
    Object? teacherName = null,
    Object? createdAt = null,
    Object? students = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      students: null == students
          ? _value.students
          : students // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomModelImplCopyWith<$Res>
    implements $ClassroomModelCopyWith<$Res> {
  factory _$$ClassroomModelImplCopyWith(_$ClassroomModelImpl value,
          $Res Function(_$ClassroomModelImpl) then) =
      __$$ClassroomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String subject,
      String teacherId,
      String teacherName,
      @TimestampConverter() DateTime createdAt,
      List<String> students});
}

/// @nodoc
class __$$ClassroomModelImplCopyWithImpl<$Res>
    extends _$ClassroomModelCopyWithImpl<$Res, _$ClassroomModelImpl>
    implements _$$ClassroomModelImplCopyWith<$Res> {
  __$$ClassroomModelImplCopyWithImpl(
      _$ClassroomModelImpl _value, $Res Function(_$ClassroomModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subject = null,
    Object? teacherId = null,
    Object? teacherName = null,
    Object? createdAt = null,
    Object? students = null,
  }) {
    return _then(_$ClassroomModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      students: null == students
          ? _value._students
          : students // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomModelImpl implements _ClassroomModel {
  const _$ClassroomModelImpl(
      {required this.id,
      required this.name,
      required this.subject,
      required this.teacherId,
      required this.teacherName,
      @TimestampConverter() required this.createdAt,
      required final List<String> students})
      : _students = students;

  factory _$ClassroomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String subject;
  @override
  final String teacherId;
  @override
  final String teacherName;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  final List<String> _students;
  @override
  List<String> get students {
    if (_students is EqualUnmodifiableListView) return _students;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_students);
  }

  @override
  String toString() {
    return 'ClassroomModel(id: $id, name: $name, subject: $subject, teacherId: $teacherId, teacherName: $teacherName, createdAt: $createdAt, students: $students)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._students, _students));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, subject, teacherId,
      teacherName, createdAt, const DeepCollectionEquality().hash(_students));

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomModelImplCopyWith<_$ClassroomModelImpl> get copyWith =>
      __$$ClassroomModelImplCopyWithImpl<_$ClassroomModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomModelImplToJson(
      this,
    );
  }
}

abstract class _ClassroomModel implements ClassroomModel {
  const factory _ClassroomModel(
      {required final String id,
      required final String name,
      required final String subject,
      required final String teacherId,
      required final String teacherName,
      @TimestampConverter() required final DateTime createdAt,
      required final List<String> students}) = _$ClassroomModelImpl;

  factory _ClassroomModel.fromJson(Map<String, dynamic> json) =
      _$ClassroomModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get subject;
  @override
  String get teacherId;
  @override
  String get teacherName;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  List<String> get students;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomModelImplCopyWith<_$ClassroomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
