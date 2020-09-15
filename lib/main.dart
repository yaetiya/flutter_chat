import 'package:flutter/cupertino.dart';
import 'package:testMessanger/screens/HomeScreen.dart';
import 'package:testMessanger/style/palette.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        //For material components in cup.app
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: myMessagesColor,
          barBackgroundColor: defaultBackgrounColor,
          scaffoldBackgroundColor: defaultBackgrounColor,
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen());
  }
}
