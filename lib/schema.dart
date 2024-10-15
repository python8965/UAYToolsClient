import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:io' show Platform;

part 'schema.freezed.dart';
part 'schema.g.dart';

typedef UuidString = String;

var DEBUG_SERVER_LOCATION = Platform.isAndroid ? "10.0.2.2:3000" :"localhost:3000";

@freezed
class Message with _$Message {
  const factory Message({
    required UuidString  id,
    required User author,
    required String content,
    required List<Attachment> attachments,

    required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required UuidString  id,
    required UuidString message_id,
    required String filename,
    required int size,

    required String url,
    required String content_type,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, Object?> json) =>
      _$AttachmentFromJson(json);
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