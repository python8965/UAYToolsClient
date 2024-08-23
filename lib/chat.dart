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

    // final channel = WebSocketChannel.connect(
    //   Uri.parse('wss://localhost'),
    // );

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
      body: SingleChildScrollView(
        child: Column(
          children: [
              // StreamBuilder(
              //   stream: channel.stream,
              //   builder: (context, snapshot) {
              //     return Expanded(
              //       child: ListView.builder(
              //           itemCount: 20,
              //           itemBuilder: (context, index) {
              //             return Container(
              //               height: 50,
              //               color: Colors.amber,
              //               child: Text("Sample Entry")
              //             );
              //           },
              //       ),
              //     );
              //   }
              // ),

            TextField(
              decoration: InputDecoration(
                labelText: "전송",
                hintText: "여기에 텍스트 입력",
              ),
              onChanged: (value) => setState(() {
                sendText = value;
              }),
            )


          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
