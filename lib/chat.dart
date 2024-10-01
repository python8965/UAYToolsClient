// chat.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uay_tools/chat_page/message_widget.dart';
import 'package:uay_tools/request.dart';
import 'package:uay_tools/schema.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

    Uri uri = Uri.http(SERVER_LOCATION, '/messages', queryParams);

    logger.d(uri.toString());

    var header = {
      "Content-Type": "application/json; charset=UTF-8",
      "charset": "UTF-8",
    };

    var response = await http.get(uri, headers: header);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);



      List<MessageData> messageDatas = [];


      MessageContext messageContext = MessageContext(DateTime.timestamp(), const Uuid().v4());

      for (var data in json["messages"]){
        var message = Message.fromJson(data);
        var (messageData, ctx) = MessageData.fromMessage(message, messageContext);

        messageContext = ctx;

        messageDatas.add(messageData);
      }

      state = messageDatas;

      return true;
    } else {
      logger.w("cannot receive messages");

      return false;
    }
  }

  Future<bool> addMessage(MessageData message) async {
    Uri uri = Uri.http(SERVER_LOCATION, '/messages');

    var header = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode(message.message);

    var response = await http.post(uri, headers: header, body:  body);

    if (response.statusCode == 200) {
      state = [message, ...state.take(99)];
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeMessage(MessageData message) async {
    Uri uri = Uri.http(SERVER_LOCATION, '/messages/${message.message.id}');

    var header = {
      "Content-Type": "application/json",
    };

    var response = await http.delete(uri, headers: header);

    if (response.statusCode == 200) {
      final index = state.indexWhere((x) => x.message.id == message.message.id);

      if (state[index].isSpacing && !state[index].isDisplayMetadata){
        state.elementAtOrNull(index + 1)?.isSpacing = true;
      }

      if (state[index].isDisplayMetadata){
        if (index - 1 < 0) {state.elementAtOrNull(index - 1);}
      }

      state.removeAt(index);
      state = [...state];

      return true;
    } else {
      return false;
    }

  }
}

class MessageData {
  bool isDisplayMetadata;
  bool isSpacing;
  Message message;

  MessageData({required this.message, required this.isDisplayMetadata, required this.isSpacing});

  @override
  String toString() {
    return message.toString();
  }

  static (MessageData, MessageContext)  fromMessage(Message message, MessageContext messageContext) {
    final timestamp = message.timestamp;

    MessageData data = MessageData(message: message, isDisplayMetadata: true, isSpacing: false);

    final diffTime = timestamp.difference(messageContext.previousTime).abs();

    if (diffTime < const Duration(seconds: 2) &&
        messageContext.id == message.author.id) { // 2초 이내에 채팅을 쳤다면 context 초기화
      messageContext = MessageContext(timestamp, message.author.id);
      data.isDisplayMetadata = false;
      data.isSpacing = false;
    } else if (diffTime < const Duration(seconds: 10) &&
        messageContext.id == message.author.id) {
      data.isDisplayMetadata = false;
      data.isSpacing = false;
    }

    if (diffTime > const Duration(seconds: 10) || messageContext.id != message.author.id) { // 10초가 지났다면 띄움
      messageContext = MessageContext(timestamp, message.author.id);
    }

    logger.i([diffTime, data.isDisplayMetadata, data.isSpacing, messageContext.id]);

    return (data, messageContext);
  }
}

class MessageContext {
  final DateTime previousTime;
  final String id;

  MessageContext(this.previousTime, this.id);
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
  int? hoverID;

  MessageContext messageContext = MessageContext(DateTime.timestamp(), const Uuid().v4());
  bool isLoaded = false;

  void _sendMessage() async  {
    final text = _controller.text.trim();


    if (text.isNotEmpty && myUuid != null) {

      final timestamp = DateTime.timestamp();

      final uuid = myUuid!;

      final message = Message(id: const Uuid().v4(), author: User(id: uuid, username: "TestUser"), content: text, timestamp: timestamp);


      var (messageData, ctx) = MessageData.fromMessage(message, messageContext);
      messageContext= ctx;

      bool v = await ref.watch(messagesRepositoryProvider.notifier).addMessage(messageData);


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

        if(context.mounted) {
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
    final colorScheme = Theme.of(context).colorScheme;

    final AsyncValue<User> userId = ref.watch(getUserProvider);

    myUuid = userId.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('단일 서버 채팅'),
        actions: [
            switch (userId) {

              // TODO: Handle this case.
              AsyncData(:final value) => Text(value.toString()),
              AsyncError() => const Text("Error Username"),
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
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh
              ),
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        '메시지가 없습니다.',
                        style: TextStyle(color: colorScheme.onSurface  ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(0.0),
                      itemCount: messages.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {

                        final message = messages[index];


                        //final nextMessage = message.length messages[messages.length-1 - index - 1];
                        return MessageWidget(message);
                      },
                    ),
            ),
          ),
          // 메시지 입력 필드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            color: colorScheme.surfaceContainerHigh,
            child: Row(
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
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
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
          ),
        ],
      ),
    );
  }

  // 타임스탬프 형식 지정 함수

}
