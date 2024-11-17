import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:fetch_client/fetch_client.dart';
import 'package:uuid/uuid.dart';

import '../chat.dart';
import '../request.dart';
import '../schema.dart';
import '../tools.dart';


part 'provider.g.dart';

@riverpod
Future<Uint8List> attachment(AttachmentRef ref, String url) async {
  final response = await http.get(Uri.http(SERVER_LOCATION, url));

  return response.bodyBytes;
}

@riverpod
class MessagesRepository extends _$MessagesRepository {
  @override
  List<MessageData> build() => [];

  Future<bool> loadMessages() async {
    var queryParams = {
      "amount": '100',
    };

    Uri uri = Uri.http(SERVER_LOCATION, '/messages', queryParams);

    logger.d(uri.toString());

    var header = {
      "Content-Type": "application/json; charset=UTF-8",
    };

    var response = await getClient().get(uri, headers: header);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      List<MessageData> messageDatas = [];

      MessageContext messageContext =
      MessageContext(DateTime.timestamp(), const Uuid().v4());

      for (var data in json["messages"]) {
        var message = Message.fromJson(data);

        var metadata = messageContext.metadataFromContext(
            message, messageDatas.lastOrNull);

        messageDatas.add(MessageData(data: message, metaData: metadata));
      }

      state = messageDatas;

      return true;
    } else {
      logger.w("cannot receive messages");

      return false;
    }
  }

  Future<bool> addMessage(EditingMessage editingMessage, MessageMetaData metadata) async {
    Uri uri = Uri.http(SERVER_LOCATION, '/messages');

    var header = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode(editingMessage.message);

    var response = await getClient().post(uri, headers: header, body: body);

    Future<Attachment?> addAttachment(SendAttachment attachment) async {
      var header = {
        "Content-Type": "multipart/form-data; charset=utf-8",
      };

      Uri uri = Uri.http(SERVER_LOCATION, '/attachment');

      var request = http.MultipartRequest('POST', uri);

      var body = {
        "id" : attachment.id,
        "message_id": editingMessage.message.id,
        "filename" :attachment.filename,
        "content_type": attachment.contentType.toString(),
        "size" : attachment.size
      };

      var bodyJson = jsonEncode(body);

      final bodyFile = http.MultipartFile.fromBytes('body', utf8.encode(bodyJson),
          contentType: MediaType("application", "json"), filename: 'body.json');

      final attachmentFile = http.MultipartFile.fromBytes('mainFile', await attachment.stream?.first ?? [],
          contentType: attachment.contentType, filename: attachment.filename);

      request.files.add(bodyFile);
      request.files.add(attachmentFile);

      final stream = await request.send();
      var response = await http.Response.fromStream(stream);


      final res = Attachment.fromJson(jsonDecode(response.body));

      if (response.statusCode == 200) {
        return res;
      } else {
        return null;
      }
    }

    List<Attachment> receivedAttachments = [];

    for (var attachment in editingMessage.attachment) {
      logger.i(attachment.toString());

      final response = await addAttachment(attachment);

      if (response == null){
        return false;
      }else {
        receivedAttachments.add(response);
      }
    }

    editingMessage.message = editingMessage.message.copyWith(attachments: receivedAttachments);

    logger.i("received attachments ${receivedAttachments}");

    if (response.statusCode == 200) {
      state = [...state.take(99), MessageData(data: editingMessage.message, metaData: metadata)];
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeMessage(MessageData message) async {
    Uri uri = Uri.http(
      SERVER_LOCATION,
      '/messages/${message.data.id}',
    );

    var header = {
      "Content-Type": "application/json",
    };

    var response = await getClient().delete(uri, headers: header);

    if (response.statusCode == 200) {
      final index = state.indexWhere((x) => x.data.id == message.data.id);

      if (state[index].metaData.isSpacing) {
        state
            .elementAtOrNull(index - 1)
            ?.metaData.isSpacing = true;
      }

      if (state[index].metaData.isDisplayMetadata) {
        logger.i(
            "isDisplayMetaData $index ${state.elementAtOrNull(index + 1)}");
        state
            .elementAtOrNull(index + 1)
            ?.metaData.isDisplayMetadata = true;
      }

      state.removeAt(index);
      state = [...state];

      return true;
    } else {
      return false;
    }
  }
}