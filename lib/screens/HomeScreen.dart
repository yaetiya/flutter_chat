import 'package:flutter/cupertino.dart';
import 'package:testMessanger/style/palette.dart';

import 'ChatScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CupertinoTextField(
                    placeholder: "Your Username",
                    controller: usernameController,
                  ),
                  CupertinoButton(
                    child: Text(
                      "...${"start".toUpperCase()}...",
                      style: TextStyle(
                          color: defaultBackgrounColor,
                          backgroundColor: myMessagesColor,
                          fontFamily: "RedRose",
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) {
                          return ChatScreen(
                            username:
                                (usernameController.text.trim().isNotEmpty)
                                    ? (usernameController.text)
                                    : ("test"),
                          );
                        },
                      ));
                    },
                  )
                ],
              ))),
    );
  }
}
