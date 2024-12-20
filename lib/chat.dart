// chat.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uay_tools/chat/message_widget.dart';
import 'package:uay_tools/request.dart';
import 'package:uay_tools/schema.dart';
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart';

import 'chat/provider.dart';
import 'tools.dart';

class EditingMessage {
  Message message;
  List<SendAttachment> attachment;

  EditingMessage(this.message, this.attachment);
}

class MessageMetaData {
  bool isDisplayMetadata;
  bool isSpacing;

  MessageMetaData({required this.isDisplayMetadata, required this.isSpacing});
}

class MessageData {
  MessageMetaData metaData;
  Message data;

  MessageData({required this.data, required this.metaData});

  @override
  String toString() {
    return [data.toString(), metaData].toString();
  }
}

class MessageContext {
  DateTime previousTime;
  String previousId;

  MessageContext(this.previousTime, this.previousId);

  MessageMetaData metadataFromContext(
      Message message, MessageData? previousMessageData) {
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

  List<SendAttachment> attachments = [];

  MessageContext messageContext =
      MessageContext(DateTime.timestamp(), const Uuid().v4());
  bool isLoaded = false;

  void _sendMessage() async {
    final text = _controller.text.trim();

    if (myUuid != null && (text.isNotEmpty || attachments.isNotEmpty)) {
      final timestamp = DateTime.timestamp();

      final uuid = myUuid!;

      final message = Message(
          id: const Uuid().v4(),
          author: User(id: uuid, username: "TestUser"),
          content: text,
          timestamp: timestamp,
          attachments: []);

      var messageMetaData = messageContext.metadataFromContext(
          message, ref.watch(messagesRepositoryProvider).lastOrNull);

      final current = EditingMessage(message, attachments);

      bool isSuccess = await ref
          .watch(messagesRepositoryProvider.notifier)
          .addMessage(current, messageMetaData);

      attachments.clear();

      if (!isSuccess) {
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

    final colorScheme = Theme.of(context).colorScheme;

    final AsyncValue<User> userId = ref.watch(getUserProvider);

    try {
      myUuid = userId.value?.id;
    } catch (e) {
      myUuid = null;
    }

    Widget buildAttachment(SendAttachment attachment) {
      final width = MediaQuery.of(context).size.width;

      return Card(
          margin: EdgeInsets.all(4.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -10.0,
                right: -10.0,
                child: FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      if (!attachments.remove(attachment)) {
                        logger.e("attachment remove not successful.");
                      }
                    });
                  },
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
                        attachment.contentType.toString(),
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
        T? tryCast<T>(dynamic x) {
          try {
            return (x as T);
          } catch (_) {
            return null;
          }
        }

        for (var item in event.session.items) {
          final id = Uuid().v4();

          // data reader is available now
          final reader = item.dataReader!;

          final formats = reader.getFormats(Formats.standardFormats);

          logger.d("performDrop ${reader.getFormats(Formats.standardFormats)}");

          bool isFileReceived = false;
          bool isValueReceived = false;

          for (var format in formats) {


            if (format == Formats.htmlFile || format == Formats.htmlText) {
              continue;
            }

            SimpleValueFormat? valueFormat = tryCast<SimpleValueFormat>(format);
            SimpleFileFormat? fileFormat = tryCast<SimpleFileFormat>(format);

            logger.d("ohh ${valueFormat} ${fileFormat}");

            if (valueFormat != null) {
              reader.getValue(Formats.fileUri, (file) async {
                logger.d(file?.path);
              });

              if (format == Formats.plainText) {
                isValueReceived = true;

                reader.getValue(Formats.plainText, (file) async {
                  logger.d("plain text ${file!.runes.string}");



                  setState(() {
                    _controller.text = file.runes.string;
                  });
                });
              }


              continue;
            }

            if (fileFormat != null) {
              logger.i(
                  "dropped Item can provide ${fileFormat.providerFormat}/${fileFormat} and type is ${format}");

              isFileReceived= true;

              reader.getFile(fileFormat, (file) async {
                // Binary files may be too large to be loaded in memory and thus
                // are exposed as stream.
                final stream = file.getStream();



                logger.i(reader.getFormats(Formats.standardFormats));

                logger.i(fileFormat.mimeTypes);

                final contentTypeString = MediaType.parse(
                    fileFormat.mimeTypes?.firstOrNull ??
                        "application/octet-stream");

                final attachment = SendAttachment(
                    id: id,
                    filename: file.fileName ??
                        await reader.getSuggestedName() ??
                        "temp_${id.toString()}",
                    contentType: contentTypeString,
                    size: file.fileSize ?? 0,
                    stream: stream);

                logger.d(attachment);

                attachments.add(attachment);

                setState(() {
                  attachments = attachments;
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

          if (!(isValueReceived || isFileReceived)) {
            final vfile = await reader.getVirtualFileReceiver();

            if (vfile != null) {
              logger.t(vfile.format);

              final (f, p) = vfile.receiveVirtualFile();
              final s = f.asStream();

              await for (var virtualFile in s){
                final contentTypeString = MediaType.parse("application/octet-stream");

                final stream  = Stream.value(await virtualFile.readNext());

                final attachment = SendAttachment(
                    id: id,
                    filename: await reader.getSuggestedName() ??
                        "temp_${id.toString()}",
                    contentType: contentTypeString,
                    size: virtualFile.length ?? 0,
                    stream: stream);

                logger.d(attachment);

                attachments.add(attachment);

                setState(() {
                  attachments = attachments;
                });
              }


            }
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
                  if (attachments.isNotEmpty)
                    SizedBox(
                      height: 150.0,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(2.0),
                        itemCount: attachments.length ?? 0,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final attachment = attachments[index];

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
                            onSubmitted: (_) {
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
