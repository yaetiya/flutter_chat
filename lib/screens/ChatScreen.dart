import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:testMessanger/blocks/messageGroup.dart';
import 'package:testMessanger/style/palette.dart';
import 'package:web_socket_channel/io.dart';

//TODO
//After tern off the LTE -> terning in on
//the reconnection does not go
//handler for losting the connection process

class ChatScreen extends StatefulWidget {
  final String username;
  ChatScreen({Key key, @required this.username}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageInputController = TextEditingController();
  //For scrolling bottom after new message
  ScrollController _scrollController = ScrollController();
  IOWebSocketChannel channel;
  //list of messages
  List<OneMessage> allMessages;
  bool isConnected = false;

  int counter = 0;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
        "ws://pm.tada.team/ws?name=${widget.username}");
    allMessages = [];
    reconnectCycle();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: isConnected ? (Text("Connected")) : Text("Reconecting"),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                print(counter++);
                if (snapshot.hasError) {
                  return Center(
                    child: Text("No internet connection"),
                  );
                } else {
                  if (snapshot.hasData) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      messageGroupBuilder(snapshot);
                    });
                    return messageGroup(size, allMessages, _scrollController);
                  } else {
                    return Center(child: CupertinoActivityIndicator());
                  }
                }
              },
            ),
            sendingGroupBuilder(size),
          ],
        ),
      ),
    );
  }

  messageGroupBuilder(snapshot) {
    setState(() {
      isConnected = true;
    });
    final parsedJson = json.decode(snapshot.data);
    if (parsedJson["name"] == null) {
      parsedJson["name"] = "";
    }
    OneMessage simpleMessage = OneMessage(
        parsedJson["text"],
        parsedJson["name"],
        (parsedJson["name"] == widget.username) ? (true) : (false));
    if (allMessages.isNotEmpty) {
      if (allMessages.last.name != simpleMessage.name &&
          allMessages.last.text != simpleMessage.text) {
        setState(() {
          allMessages = [...allMessages, simpleMessage];
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 100,
              curve: Curves.easeInCirc,
              duration: Duration(milliseconds: 400));
        });
      }
    } else {
      setState(() {
        allMessages = [simpleMessage];
      });
    }
  }

  Widget sendingGroupBuilder(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
          decoration: BoxDecoration(color: defaultBackgrounColor),
          width: size.width,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30,
                  width: size.width * 0.7,
                  child: CupertinoTextField(
                    placeholderStyle:
                        TextStyle(color: lightColor, fontSize: 14),
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: lightColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
                    controller: _messageInputController,
                    placeholder: "Message",
                  ),
                ),
                GestureDetector(
                  onTap: () => (sendMessage()),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.send,
                      color: myMessagesColor,
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  void sendMessage() {
    if (isConnected) {
      if (_messageInputController.text.isNotEmpty) {
        String message = json.encode({
          'text': _messageInputController.text,
        });
        channel.sink.add(message);
        _messageInputController.text = "";
      }
    } else {
      reconnect();
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void reconnect() {
    Future.delayed(Duration(microseconds: 800), () {
      setState(() {
        channel = IOWebSocketChannel.connect(
            "ws://pm.tada.team/ws?name=${widget.username}");
      });
    });
  }

  void reconnectCycle() {
    Future.delayed(Duration(microseconds: 2000), () {
      reconnect();
      reconnectCycle();
    });
  }
}

class OneMessage {
  bool isMyMessage;
  String text;
  String name;
  OneMessage(this.text, this.name, this.isMyMessage);
}
