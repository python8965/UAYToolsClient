import 'package:freezed_annotation/freezed_annotation.dart';

part 'schema.freezed.dart';
part 'schema.g.dart';

typedef UUid = String;

@freezed
class Message with _$Message {
  const factory Message({
    required UUid id,
    required User user,
    required String content,
    required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required UUid id,
    required String username,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) =>
      _$UserFromJson(json);
}