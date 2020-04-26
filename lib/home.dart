import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testyourmask/values.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'grade.dart';

class Home extends StatefulWidget {
  static var routeName = '/home';

  bool isLoading = false;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = const MethodChannel('com.rocinante.tym/battery');
  String _sensorValues = "Unkown sensor values";
  Grade grade = Grade();
  static int duration = 5;
  final values = Values();

  Future<void> _getSensorValues() async {
    setState(() {
      widget.isLoading = true;
    });

    var result;
    String sensorValues;
    try {
      await platform.invokeMethod('fetchValues');

      sleep(Duration(seconds: duration));

      result = await platform.invokeMethod('getSensorValue');
      sensorValues = '$result';
    } on PlatformException catch (e) {
      result = "Failed to get sensor values: '${e.message}'.";
    }
    this.grade = Grade.withSensorValues(sensorValues);
    setState(() {
      _sensorValues = sensorValues;
      widget.isLoading = false;
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

    return Scaffold(
      appBar: AppBar(
        title: Text("watch intro", style: TextStyle(fontSize: 14),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
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
                  Text('Grade: ${grade.grade}'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: widget.isLoading
                        ? Text("LOADING!")
                        : Text(_sensorValues),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Get Sensor Values',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    onPressed: _getSensorValues,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
