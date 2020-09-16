import 'dart:async';
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
  List<OneMessage> sendingMessages;
  bool isConnected = false;

  int counter = 0;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
        "ws://pm.tada.team/ws?name=${widget.username}");
    allMessages = [];
    sendingMessages = [];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.delete_simple),
          onTap: () {
            deleteUnsentMessages();
          },
        ),
        middle: GestureDetector(
          child: Text("Reconnect"),
          onTap: () {
            reconnectWithDuration(100);
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    messageGroupBuilder(snapshot);
                  });
                  return messageGroup(
                      size, allMessages, _scrollController, sendingMessages);
                } else {
                  return messageGroup(
                      size, allMessages, _scrollController, sendingMessages);
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
        (parsedJson["name"] == widget.username) ? (true) : (false),
        true);
    if (allMessages.isNotEmpty) {
      if (allMessages.last.name != simpleMessage.name &&
          allMessages.last.text != simpleMessage.text) {
        if (simpleMessage.isMyMessage) {
          sendingMessages
              .removeWhere((element) => element.text == simpleMessage.text);
        }
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
    if (_messageInputController.text.isNotEmpty) {
      setState(() {
        if (!(sendingMessages.isEmpty && allMessages.isEmpty)) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 100,
              curve: Curves.easeInCirc,
              duration: Duration(milliseconds: 400));
        }
        sendingMessages = [
          ...sendingMessages,
          OneMessage(_messageInputController.text, widget.username, true, false)
        ];
      });
      String message = json.encode({
        'text': _messageInputController.text,
      });
      channel.sink.add(message);
      _messageInputController.text = "";
    }
    if (!isConnected) {
      // if (_messageInputController.text.isNotEmpty) {
      //   setState(() {
      //     sendingMessages = [
      //       ...sendingMessages,
      //       OneMessage(
      //           _messageInputController.text, widget.username, true, false)
      //     ];
      //     _scrollController.animateTo(
      //         _scrollController.position.maxScrollExtent + 100,
      //         curve: Curves.easeInCirc,
      //         duration: Duration(milliseconds: 400));
      //   });
      //   String message = json.encode({
      //     'text': _messageInputController.text,
      //   });
      //   channel.sink.add(message);
      //   _messageInputController.text = "";
      // }
      reconnectWithDuration(500);
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  deleteUnsentMessages() {
    setState(() {
      sendingMessages = [];
    });
  }

  reconnectWithDuration(int duration) {
    print("reconnect");
    Future.delayed(Duration(microseconds: duration), () {
      setState(() {
        channel = IOWebSocketChannel.connect(
            "ws://pm.tada.team/ws?name=${widget.username}");
      });
    });
  }
}

class OneMessage {
  bool isMyMessage;
  bool isSended;
  String text;
  String name;
  OneMessage(this.text, this.name, this.isMyMessage, this.isSended);
}
