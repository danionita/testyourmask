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
            primaryColor: Color.fromRGBO(163, 201, 250, 1),
            accentColor: Color.fromRGBO(59, 129, 128, 1),
            fontFamily: 'Avenir',
          ),
          home: Intro(),
          routes: {
            Home.routeName: (ctx) => Home(),
          },
        ));
  }
}
