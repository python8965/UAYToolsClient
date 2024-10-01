import 'package:freezed_annotation/freezed_annotation.dart';

part 'schema.freezed.dart';
part 'schema.g.dart';

typedef UuidString = String;

const SERVER_LOCATION = "localhost:3000";

@freezed
class Message with _$Message {
  const factory Message({
    required UuidString  id,
    required User author,
    required String content,
    required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required UuidString  id,
    required String username,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) =>
      _$UserFromJson(json);
}