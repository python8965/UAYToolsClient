import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../chat.dart';
import '../context_menu.dart';

class MessageWidget extends ConsumerStatefulWidget{
  final MessageData messageData;

  const MessageWidget(this.messageData, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageWidgetState();

}

class _MessageWidgetState extends ConsumerState<MessageWidget>{
  bool isHovered = false;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  UnimplementedToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Text("Unimplemented!"),
    );

    fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {


    final colorScheme = Theme.of(context).colorScheme;

    final messageData = widget.messageData;

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          showContextMenu(Offset globalPosition) {
            final position = RelativeRect.fromLTRB(
                globalPosition.dx, globalPosition.dy, globalPosition.dx, 200);
            final textMenu = TextContextMenuCallback(
                onEdit: UnimplementedToast, onReply: UnimplementedToast, onCopy: UnimplementedToast, onDelete: () {
              ref.watch(messagesRepositoryProvider.notifier).removeMessage(messageData);
            });

            ContextMenuBuilder(
                context: context,
                contextMenuCallback: textMenu,
                position: position)
                .showContextMenu();
          }

          final textUi = MouseRegion(
            onEnter: (_) {
              setState(() => isHovered = true);
            },
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onLongPressStart: (x) => showContextMenu(x.globalPosition),
              onSecondaryTapUp: (x) => showContextMenu(x.globalPosition),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 0.0),
                color: isHovered ? colorScheme.surfaceContainerHighest: colorScheme.surfaceContainerHigh,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8.0),
                    messageData.isDisplayMetadata
                        ? CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        messageData.message.author.username[0].toUpperCase(),
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                    )
                        : const SizedBox(width: 40.0),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (messageData.isDisplayMetadata)
                            Row(
                              children: [
                                Text(
                                  messageData.message.author.username,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimestamp(messageData.message.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 2),
                          Text(
                            messageData.message.content,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
            ),
          );

          if (messageData.isSpacing) {
            return Column(
              children: [
                textUi,
                const SizedBox(height: 20.0)
              ],
            );
          } else {
            return textUi;
          }
        });
  }

  String _formatTimestamp(DateTime timestamp) {
    final time = TimeOfDay.fromDateTime(timestamp);
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

}