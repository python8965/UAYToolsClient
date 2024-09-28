// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      uuid: json['uuid'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isDisplayMetadata: json['isDisplayMetadata'] as bool,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'username': instance.username,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'isDisplayMetadata': instance.isDisplayMetadata,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesRepositoryHash() =>
    r'e7d5b4c3b564e12e1d3f26defcf772a1914d9804';

/// See also [MessagesRepository].
@ProviderFor(MessagesRepository)
final messagesRepositoryProvider =
    AutoDisposeNotifierProvider<MessagesRepository, List<Message>>.internal(
  MessagesRepository.new,
  name: r'messagesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messagesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessagesRepository = AutoDisposeNotifier<List<Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
