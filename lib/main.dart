import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testyourmask/values.dart';

import 'grade.dart';
import 'home.dart';
import 'intro.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Values(),
          ),
          ChangeNotifierProvider.value(
            value: Grade(),
          )
        ],
        child: MaterialApp(
          title: 'Test Your Mask',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color.fromRGBO(64, 79, 98, 1),
            accentColor: Color.fromRGBO(23, 51, 78, 1),
            fontFamily: 'Avenir',
          ),
          home: Intro(),
          routes: {
            Home.routeName: (ctx) => Home(),
          },
        ));
  }
}
