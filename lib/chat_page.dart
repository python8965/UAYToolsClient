// chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_page.freezed.dart';
part 'chat_page.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String username,
    required String content,
    required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) => _$MessageFromJson(json);

}


class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final String currentUsername = "TestUser"; // 현재 사용자 이름

  void _sendMessage() {
    final text = _controller.text.trim();

  }

  @override
  Widget build(BuildContext context) {
    final messages = [
      Message(username: "AKETON", content: "Test01", timestamp: DateTime(0))
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('단일 서버 채팅'),
        backgroundColor: const Color(0xFF40444B),
      ),
      body: Column(
        children: [
          // 채팅 이력 표시
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2F3136),
              ),
              child: messages.isEmpty
                  ? const Center(
                child: Text(
                  '메시지가 없습니다.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final isMe = message.username == currentUsername;
                  return _buildMessageTile(message);
                },
              ),
            ),
          ),
          // 메시지 입력 필드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            color: const Color(0xFF2F3136),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // 이미지 업로드 등 추가 기능
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF40444B),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 개별 메시지 위젯
  Widget _buildMessageTile(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                message.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  message.content,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 2),

              ],
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  // 타임스탬프 형식 지정 함수
  String _formatTimestamp(DateTime timestamp) {
    final time = TimeOfDay.fromDateTime(timestamp);
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}