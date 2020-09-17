import 'package:flutter/cupertino.dart';
import 'package:testMessanger/screens/ChatScreen.dart';
import 'package:testMessanger/style/palette.dart';

import '../compoents/message.dart';

Widget messageGroup(Size size, List<OneMessage> allMessages,
    ScrollController _scrollController, List<OneMessage> sendingMessages) {
  return (!(allMessages.isEmpty && sendingMessages.isEmpty))
      ? (Positioned(
          left: 0,
          bottom: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Container(
                decoration: BoxDecoration(color: defaultBackgrounColor),
                width: size.width - 26,
                constraints: BoxConstraints(maxHeight: size.height - 130),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      ...allMessages.map((e) => message(
                          size, e.isMyMessage, e.text, e.name, e.isSended)),
                      ...sendingMessages.map((e) => message(
                          size, e.isMyMessage, e.text, e.name, e.isSended))
                    ],
                  ),
                )),
          ),
        ))
      : (Center(
          child: Text("Пока нет сообщений"),
        ));
}
