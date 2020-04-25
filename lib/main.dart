import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testyourmask/values.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Values(),
        )
      ],
      child: MaterialApp(
        title: 'Test Your Mask',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('com.rocinante.tym/battery');
  String _sensorValues = "Unkown sensor values";

  Future<void> _getSensorValues() async {
    var result;
    String sensorValues;
    try {
      await platform.invokeMethod('fetchValues');

      sleep(Duration(seconds:5));

      result = await platform.invokeMethod('getSensorValue');
      sensorValues = '$result';
    } on PlatformException catch (e) {
      result = "Failed to get sensor values: '${e.message}'.";
    }

    setState(() {
      _sensorValues = sensorValues;
    });
  }

  @override
  Widget build(BuildContext context) {
    final values = Provider.of<Values>(context);

    platform.setMethodCallHandler((call) {
      if (call.method == 'ledRed') {
        values.changeRed(call.arguments.toString());
      } else if (call.method == 'ledIr') {
        values.changeIr(call.arguments.toString());
      }
    });

    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://i.pinimg.com/236x/83/13/bb/8313bbedf58b9576f36de321c96db50f.jpg'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('IrValue: ${values.irValue}'),
                Text('RedValue: ${values.redValue}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text('Get Sensor Values'),
                  onPressed: _getSensorValues,
                )
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Text(_sensorValues),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
