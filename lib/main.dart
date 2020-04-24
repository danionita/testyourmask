import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Your Mask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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


  String _batteryLevel = 'Unknown battery level.';

  String _sensorValues = "Unkown sensor values";

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getSensorValues() async {
    var result;
    String sensorValues;
    try {
      result = await platform.invokeMethod('getSensorValue');
      sensorValues = 'Sensor at $result % .';

    } on PlatformException catch (e) {
      result = "Failed to get sensor values: '${e.message}'.";
    }

    setState(() {
      _sensorValues = sensorValues;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            RaisedButton(
              child: Text('Get Battery Level'),
              onPressed: _getBatteryLevel,
            ),
            Text(_batteryLevel),
            RaisedButton(
              child: Text('Get Sensor Values'),
              onPressed: _getSensorValues,
            ),
            Text(_sensorValues),
          ],
        ),
      ),
    );
  }
}
