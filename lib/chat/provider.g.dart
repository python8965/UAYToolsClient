// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentHash() => r'9385c94432c00dedab7642daa4918f70e5ed23b3';

/// See also [attachment].
@ProviderFor(attachment)
final attachmentProvider = AutoDisposeFutureProvider<Attachment>.internal(
  attachment,
  name: r'attachmentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$attachmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AttachmentRef = AutoDisposeFutureProviderRef<Attachment>;
String _$messagesRepositoryHash() =>
    r'c12ad7ef15736e72e846debc3de69e9426e373c6';

/// See also [MessagesRepository].
@ProviderFor(MessagesRepository)
final messagesRepositoryProvider =
    AutoDisposeNotifierProvider<MessagesRepository, List<MessageData>>.internal(
  MessagesRepository.new,
  name: r'messagesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messagesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessagesRepository = AutoDisposeNotifier<List<MessageData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
