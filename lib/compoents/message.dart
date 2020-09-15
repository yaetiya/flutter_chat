import 'package:flutter/cupertino.dart';
import 'package:testMessanger/style/palette.dart';

//Можно было сделать отдельный отрисовщик для присоединения к диалогу...
Widget message(
    Size size, bool isMyMessage, String messageText, String messageSender) {
  return Container(
    width: size.width,
    child: Column(
      crossAxisAlignment:
          (isMyMessage) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 5),
          child: Text(
            messageSender,
            style: TextStyle(color: lightColor),
          ),
        ),
        Container(
            margin: EdgeInsets.only(bottom: 14),
            constraints: BoxConstraints(maxWidth: size.width * 0.8),
            decoration: BoxDecoration(
              color: (isMyMessage) ? myMessagesColor : otherMesssagesColor,
              borderRadius: BorderRadius.all(Radius.circular(13)),
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                messageText,
                style: TextStyle(
                  color: (isMyMessage) ? defaultBackgrounColor : textColor,
                ),
              ),
            ))
      ],
    ),
  );
}
