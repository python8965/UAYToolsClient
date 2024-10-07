import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uay_tools/chat.dart';
import 'package:uay_tools/schema.dart';
import 'package:uay_tools/tools.dart';
import 'package:uuid/uuid.dart';

part 'request.g.dart';

class SendAttachment {
  UuidString  id;
  String filename;
  MediaType contentType;
  int size;

  Stream<Uint8List>? stream;

  SendAttachment(
      {required this.id, required this.filename, required this.contentType, required this.size, this.stream});

  @override
  String toString() {
    // TODO: implement toString
    return 'id : ${id.toString()}, filename : ${filename}, content_type : ${contentType}, size : ${size}, stream: ${stream.toString()}';
  }
}

@riverpod
Future<User> getUser(GetUserRef ref) async {
  Future<User> createUser(String name) async{
    Uri uri = Uri.http(DEBUG_SERVER_LOCATION, '/user');

    var header = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode({
      "username": name
    });

    var response = await http.post(uri, headers: header, body: body );

    if (response.statusCode == 200) {

      return User.fromJson(jsonDecode(response.body)) ;
    } else {
      throw Exception("Cannot reach");
    }
  }

  Future<User> getUser() async{
    Uri uri = Uri.http(DEBUG_SERVER_LOCATION, '/user');

    var header = {
      "Content-Type": "application/json",
    };

    var response = await http.get(uri, headers: header );

    if (response.statusCode == 200) {
      logger.d("found user");
      return User.fromJson(jsonDecode(response.body)) ;
    } else {
      logger.d("create new user");
      return await createUser("TestUSer");
    }
  }

  return await getUser();
}

class MyObserver extends ProviderObserver {
  @override
  void didAddProvider(
      ProviderBase<Object?> provider,
      Object? value,
      ProviderContainer container,
      ) {
    logger.t('Provider $provider was initialized with $value');
  }

  @override
  void didDisposeProvider(
      ProviderBase<Object?> provider,
      ProviderContainer container,
      ) {
    logger.t('Provider $provider was disposed');
  }

  @override
  void didUpdateProvider(
      ProviderBase<Object?> provider,
      Object? previousValue,
      Object? newValue,
      ProviderContainer container,
      ) {
    logger.t('Provider $provider updated from $previousValue to $newValue');
  }

  @override
  void providerDidFail(
      ProviderBase<Object?> provider,
      Object error,
      StackTrace stackTrace,
      ProviderContainer container,
      ) {
    logger.t('Provider $provider threw $error at $stackTrace');
  }
}