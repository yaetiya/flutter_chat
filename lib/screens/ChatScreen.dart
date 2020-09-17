import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:testMessanger/blocks/messageGroup.dart';
import 'package:testMessanger/style/palette.dart';
import 'package:web_socket_channel/io.dart';

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
          child: Text(
            "...${"tap to reconnect".toUpperCase()}...",
            style: TextStyle(
                color: defaultBackgrounColor,
                backgroundColor: myMessagesColor,
                fontFamily: "RedRose",
                fontWeight: FontWeight.bold),
          ),
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
                    final parsedJson = json.decode(snapshot.data);
                    if (parsedJson["name"] == null) {
                      parsedJson["name"] = "";
                    }

                    OneMessage simpleMessage = OneMessage(
                        parsedJson["text"],
                        parsedJson["name"],
                        (parsedJson["name"] == widget.username)
                            ? (true)
                            : (false),
                        true,
                        parsedJson["created"]);
                    bool newMessageStatus =
                        messageGroupBuilder(snapshot, simpleMessage);
                    if (newMessageStatus) {
                      scrollWithDuration();
                    }
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

  bool messageGroupBuilder(snapshot, simpleMessage) {
    if (allMessages.isNotEmpty) {
      if (isNewMessage(allMessages.last, simpleMessage)) {
        if (simpleMessage.isMyMessage) {
          sendingMessages
              .removeWhere((element) => element.text == simpleMessage.text);
        }
        setState(() {
          allMessages = [...allMessages, simpleMessage];
        });
        return true;
        // if (simpleMessage.isMyMessage) {
        //   scrollWithDuration();
        // }
      }
    } else {
      setState(() {
        allMessages = [simpleMessage];
      });
      return true;
    }
    return false;
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
      if (!(sendingMessages.isEmpty && allMessages.isEmpty)) {
        scrollWithDuration();
      }
      setState(() {
        sendingMessages = [
          ...sendingMessages,
          OneMessage(_messageInputController.text, widget.username, true, false,
              DateTime.now().toString())
        ];
      });
      String message = json.encode({
        'text': _messageInputController.text,
      });
      channel.sink.add(message);
      _messageInputController.text = "";
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

  scrollWithDuration() {
    print('object');
    Future.delayed(Duration(microseconds: 100), () {
      setState(() {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            curve: Curves.easeInCirc, duration: Duration(milliseconds: 100));
      });
    });
  }

  reconnectWithDuration(int duration) {
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
  String created;
  bool isSended;
  String text;
  String name;
  OneMessage(
      this.text, this.name, this.isMyMessage, this.isSended, this.created);
}

bool isNewMessage(OneMessage message1, OneMessage message2) {
  return ((message1.name != message2.name) |
      (message1.text != message2.text) |
      (message1.created != message2.created));
}
