// chat.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uay_tools/chat_page/message_widget.dart';
import 'package:uay_tools/request.dart';
import 'package:uay_tools/schema.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http_parser/http_parser.dart';

import 'main.dart';
import 'tools.dart';

part 'chat.g.dart';


@riverpod
class MessagesRepository extends _$MessagesRepository {
  @override
  List<MessageData> build() => [];

  Future<bool> loadMessages() async {
    var queryParams = {
      "amount": '100',
    };

    Uri uri = Uri.http(DEBUG_SERVER_LOCATION, '/messages', queryParams);

    logger.d(uri.toString());

    var header = {
      "Content-Type": "application/json; charset=UTF-8",
      "charset": "UTF-8",
    };

    var response = await http.get(uri, headers: header);

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

  Future<bool> addMessage(EditingMessage message, MessageMetaData metadata) async {
    Future<bool> addAttachment(SendAttachment attachment) async {
      var header = {
        "Content-Type": "multipart/form-data",
      };

      Uri uri = Uri.http(DEBUG_SERVER_LOCATION, '/attachment');

      var request = http.MultipartRequest('POST', uri);

      var body = {
          "id" : attachment.id,
          "filename" :attachment.filename,
          "content_type": attachment.content_type,
          "size" : attachment.size
      };

      var bodyJson = jsonEncode(body);

      final bodyFile = http.MultipartFile.fromBytes('body', bodyJson.codeUnits,
          contentType: MediaType("application", "json"), filename: 'body.json');

      final attachmentFile = http.MultipartFile.fromBytes('mainFile', await attachment.stream?.first ?? [],
          contentType: MediaType.parse(attachment.content_type), filename: attachment.filename);

      request.files.add(bodyFile);
      request.files.add(attachmentFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }

    for (var attachment in message.attachment) {
      logger.i(attachment.toString());

      final response = await addAttachment(attachment);

      if (!response){
        return false;
      }
    }

    Uri uri = Uri.http(DEBUG_SERVER_LOCATION, '/messages');

    var header = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode(message.message);

    var response = await http.post(uri, headers: header, body: body);

    if (response.statusCode == 200) {
      state = [...state.take(99), MessageData(data: message.message, metaData: metadata)];
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeMessage(MessageData message) async {
    Uri uri = Uri.http(
      DEBUG_SERVER_LOCATION,
      '/messages/${message.data.id}',
    );

    var header = {
      "Content-Type": "application/json",
    };

    var response = await http.delete(uri, headers: header);

    if (response.statusCode == 200) {
      final index = state.indexWhere((x) => x.data.id == message.data.id);

      if (state[index].metaData.isSpacing) {
        state
            .elementAtOrNull(index - 1)
            ?.metaData.isSpacing = true;
      }

      if (state[index].metaData.isDisplayMetadata) {
        logger.i(
            "isDisplayMetaData ${index} ${state.elementAtOrNull(index + 1)}");
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

class EditingMessage {
  Message message;
  List<SendAttachment> attachment;

  EditingMessage(this.message, this.attachment);
}

class MessageMetaData {
  bool isDisplayMetadata;
  bool isSpacing;

  MessageMetaData({
    required this.isDisplayMetadata,
    required this.isSpacing});
}

class MessageData {
  MessageMetaData metaData;
  Message data;

  MessageData({required this.data,
    required this.metaData});

  @override
  String toString() {
    return [data.toString(), this.metaData].toString();
  }
}

class MessageContext {
  DateTime previousTime;
  String previousId;

  MessageContext(this.previousTime, this.previousId);

  MessageMetaData metadataFromContext(Message message,
      MessageData? previousMessageData) {
    final timestamp = message.timestamp;

    var data = MessageMetaData(isDisplayMetadata: true, isSpacing: false);

    final diffTime = timestamp.difference(previousTime).abs();

    if (diffTime < const Duration(seconds: 2) &&
        previousId == message.author.id) {
      // 2초 이내에 채팅을 쳤다면 context 초기화
      previousTime = timestamp;
      previousId = message.author.id;
      data.isDisplayMetadata = false;
      data.isSpacing = false;
    } else if (diffTime < const Duration(seconds: 10) &&
        previousId == message.author.id) {
      data.isDisplayMetadata = false;
      data.isSpacing = false;
    }

    if (diffTime > const Duration(seconds: 10) ||
        previousId != message.author.id) {
      // 10초가 지났다면 띄움
      previousTime = timestamp;
      previousId = message.author.id;
    }

    if (data.isDisplayMetadata) {
      previousMessageData?.metaData.isSpacing = true;
    }

    logger.i([
      diffTime,
      data.isDisplayMetadata,
      data.isSpacing,
      previousId,
      previousMessageData
    ]);

    return data;
  }
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}



class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final String currentUsername = "TestUser"; // 현재 사용자 이름
  final FocusNode textEditFocusNode = FocusNode();

  String? myUuid;

  EditingMessage currentEditingMessage = EditingMessage(
      Message(
          id: "",
          author: User(id: "", username: ""),
          content: "",
          attachments: [

          ],
          timestamp: DateTime.timestamp()
      ), [
    ]
  );

  MessageContext messageContext =
  MessageContext(DateTime.timestamp(), const Uuid().v4());
  bool isLoaded = false;

  void _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isNotEmpty && myUuid != null) {
      final timestamp = DateTime.timestamp();

      final uuid = myUuid!;

      final message = Message(
          id: const Uuid().v4(),
          author: User(id: uuid, username: "TestUser"),
          content: text,
          timestamp: timestamp,
          attachments: []);

      var messageMetaData = messageContext.metadataFromContext(
          message, ref
          .watch(messagesRepositoryProvider)
          .lastOrNull);

      bool v = await ref
          .watch(messagesRepositoryProvider.notifier)
          .addMessage(currentEditingMessage, messageMetaData);



      if (!v) {
        final snackBar = SnackBar(
          content: Text(uuid),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      //debugPrint(ref.watch(messagesRepositoryProvider).toString());
      _controller.text = "";
    }

    textEditFocusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesRepositoryProvider);

    if (!isLoaded) {
      ref.watch(messagesRepositoryProvider.notifier).loadMessages();
      isLoaded = true;
    }

    final colorScheme = Theme
        .of(context)
        .colorScheme;

    final AsyncValue<User> userId = ref.watch(getUserProvider);

    try {
      myUuid = userId.value?.id;
    } catch (e) {
      myUuid = null;
    }

    Widget buildAttachment(SendAttachment attachment) {
      final _width = MediaQuery
          .of(context)
          .size
          .width;

      return Card(
          margin: EdgeInsets.all(4.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -10.0,
                right: -10.0,
                child: FloatingActionButton.small(
                  onPressed: () {},
                  child: Icon(Icons.close),
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 2.0,
                  ),
                  Icon(
                    Icons.file_present,
                    size: 100.0,
                  ),
                  const SizedBox(
                    width: 2.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(attachment.filename),
                      Text(
                        attachment.content_type,
                        textAlign: TextAlign.end,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ],
          ));
    }

    return DropRegion(
      // Formats this region can accept.
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        // You can inspect local data here, as well as formats of each item.
        // However on certain platforms (mobile / web) the actual data is
        // only available when the drop is accepted (onPerformDrop).
        final item = event.session.items.first;
        if (item.localData is Map) {
          // This is a drag within the app and has custom local data set.
        }
        if (item.canProvide(Formats.plainText)) {
          // this item contains plain text.
        }
        // This drop region only supports copy operation.
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          return DropOperation.copy;
        } else {
          return DropOperation.none;
        }
      },
      onDropEnter: (event) {
        // This is called when region first accepts a drag. You can use this
        // to display a visual indicator that the drop is allowed.
      },
      onDropLeave: (event) {
        // Called when drag leaves the region. Will also be called after
        // drag completion.
        // This is a good place to remove any visual indicators.
      },
      onPerformDrop: (event) async {
        // Called when user dropped the item. You can now request the data.
        // Note that data must be requested before the performDrop callback
        // is over.
        final item = event.session.items.first;

        // data reader is available now
        final reader = item.dataReader!;

        final formats = reader.getFormats(Formats.standardFormats);

        logger.d("performDrop ${reader.getFormats(Formats.standardFormats)}");

        for (var format in Formats.standardFormats) {
          if (format == Formats.plainText || format == Formats.htmlText || format == Formats.uri || format == Formats.fileUri) {
            continue;
          }

          if (reader.canProvide(format)) {
            logger.i("dropped Item can provide ${format.toString()}");

            reader.getFile(format as FileFormat?, (file) async {
              // Binary files may be too large to be loaded in memory and thus
              // are exposed as stream.
              final stream = file.getStream();

              final id = Uuid().v4();


              currentEditingMessage.attachment.add(
                  SendAttachment(id: id , filename: file.fileName ?? await reader.getSuggestedName() ?? "temp_${id.toString()}", content_type: reader.getFormats(Formats.standardFormats).first.toString(), size: file.fileSize ?? 0,stream: stream)
              );

              setState(() {
                currentEditingMessage.attachment = currentEditingMessage.attachment;
              });


              // Alternatively, if you know that that the value is small enough,
              // you can read the entire value into memory:
              // (note that readAll is mutually exclusive with getStream(), you
              // can only use one of them)
              // final data = file.readAll();
            }, onError: (error) {
              logger.d('Error reading value $error');
            });
          }
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text('단일 서버 채팅'),
          actions: [
            switch (userId) {
            // TODO: Handle this case.
              AsyncData(:final value) => const Text("Success"),
              AsyncError() => const Text("Error"),
              _ => const CircularProgressIndicator()
            }
          ],
          backgroundColor: colorScheme.surfaceContainerLowest,
        ),
        body: Column(
          children: [
            // 채팅 이력 표시
            Expanded(
              child: Container(
                decoration:
                BoxDecoration(color: colorScheme.surfaceContainerHigh),
                child: messages.isEmpty
                    ? Center(
                  child: Text(
                    '메시지가 없습니다.',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                )
                    : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(0.0),
                  itemCount: messages.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - index - 1];

                    return MessageWidget(message);
                  },
                ),
              ),
            ),
            // 메시지 입력 필드
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              color: colorScheme.surfaceContainerHigh,
              child: Column(
                children: [
                  Container(
                    height: 150.0,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(2.0),
                      itemCount: currentEditingMessage?.attachment.length ?? 0,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final attachment =
                        currentEditingMessage!.attachment[index];

                        return buildAttachment(attachment);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: colorScheme.onSurface),
                        onPressed: () {
                          // 이미지 업로드 등 추가 기능
                        },
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _controller,
                            focusNode: textEditFocusNode,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...',
                              hintStyle: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                              border: InputBorder.none,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (str) {
                              currentEditingMessage.message =
                                  currentEditingMessage.message.copyWith(content: str);

                              _sendMessage();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.send, color: colorScheme.onSurface),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 타임스탬프 형식 지정 함수
}
