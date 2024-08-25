import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:freezed_annotation/freezed_annotation.dart';



class UAYChatPage extends ConsumerStatefulWidget {
  const UAYChatPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  ConsumerState<UAYChatPage> createState() => _UAYChatPageState();
}

class _UAYChatPageState extends ConsumerState<UAYChatPage> {
  String sendText = "";
  String TargetIP = "";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final channel = WebSocketChannel.connect(
      Uri.parse('wss://localhost'),
    );

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('UAYChatPage'),
      ),
      body: Container(
          decoration: const BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)),
          ),
        child:
            Column(
              children: [
                Flexible(
                    fit: FlexFit.tight,
                    child: StreamBuilder(
                        stream: channel.stream,
                        builder: (context, snapshot) {
                            return ListView.builder(
                              itemCount: 20,
                              itemBuilder: (context, index) {
                              return Container(
                              height: 50,
                              color: Colors.amber,
                              child: Text("Sample Entry")
                              );
                              },
                        );
                  })
                ),

                sendMesssage()


              ],
            )
        ),
      ); // This trailing comma makes auto-formatting nicer for build methods.
  }


  Widget sendMesssage() => Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color.fromARGB(18, 0, 0, 0), blurRadius: 10)
        ],
        color: Colors.amber,
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},//onSendImagePressed,
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          iconSize: 25,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  iconSize: 25,
                ),
                hintText: "Type your message here",
                hintMaxLines: 1,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                hintStyle: const TextStyle(
                  fontSize: 16,
                ),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.black26,
                    width: 0.2,
                  ),
                ),
              ),
              onChanged: (value) {
                sendText = value;
              },
            )),
      ]));
}
