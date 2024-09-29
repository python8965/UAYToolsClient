// chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uay_tools/chat_page/message_widget.dart';
import 'package:uay_tools/context_menu.dart';
import 'package:uay_tools/schema.dart';
import 'package:uuid/uuid.dart';



part 'chat_page.g.dart';


class MessageData {
  bool isDisplayMetadata;
  bool isSpacing;
  Message message;

  MessageData({required this.message, required this.isDisplayMetadata, required this.isSpacing});

  @override
  String toString() {
    return message.toString();
  }
}

class MessageContext {
  final DateTime previousTime;
  final String uuid;

  MessageContext(this.previousTime, this.uuid);
}

@riverpod
class MessagesRepository extends _$MessagesRepository {
  @override
  List<MessageData> build() => [];

  void addMessage(MessageData message) {
    state = [message, ...state.take(99)];
  }

  void removeMessage(MessageData message) {

    final index = state.indexWhere((x) => x.message.id == message.message.id);

    print(index);

    if (state[index].isSpacing && !state[index].isDisplayMetadata){
        state.elementAtOrNull(index + 1)?.isSpacing = true;
    }

    if (state[index].isDisplayMetadata){
      if (index - 1 < 0) {state.elementAtOrNull(index - 1);}
    }

    state.removeAt(index);
    state = [...state];
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

  final String myUuid = const Uuid().v4();
  int? hoverID;

  MessageContext messageContext = MessageContext(DateTime.now(), const Uuid().v4());

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isNotEmpty) {
      bool displayIcon = true;

      final timestamp = DateTime.now();
      final uuid = myUuid;
      debugPrint(
          messageContext.previousTime.difference(timestamp).abs().toString());

      final diffTime = timestamp.difference(messageContext.previousTime).abs();

      if (diffTime < const Duration(seconds: 5) &&
          messageContext.uuid == uuid) {
        displayIcon = false;
        ref.watch(messagesRepositoryProvider).first.isSpacing =false;
      }

      if (diffTime > const Duration(seconds: 5)) { // 5초가 지났다면 refresh
        messageContext = MessageContext(timestamp, uuid);
      }

      var message = Message(
        id: const Uuid().v4(),
          user: User(id: myUuid, username: "Test"),
          content: text,
          timestamp: timestamp, );

      var messageData = MessageData(
        message: message,
        isDisplayMetadata: displayIcon,
        isSpacing: true
      );

      ref.watch(messagesRepositoryProvider.notifier).addMessage(messageData);

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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('단일 서버 채팅'),
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
