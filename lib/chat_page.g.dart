// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageNotifierHash() => r'49ddeefb0b8b6e8e0a83866f6cb5ca318b823219';

/// See also [MessageNotifier].
@ProviderFor(MessageNotifier)
final messageNotifierProvider =
    AutoDisposeNotifierProvider<MessageNotifier, List<Message>>.internal(
  MessageNotifier.new,
  name: r'messageNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessageNotifier = AutoDisposeNotifier<List<Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
