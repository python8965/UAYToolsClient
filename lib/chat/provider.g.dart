// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesRepositoryHash() =>
    r'f66edf35cb11dee24bdbabfe0792a28213fc3457';

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
