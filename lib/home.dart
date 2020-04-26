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
    try {
      await platform.invokeMethod('fetchValues').then((_) async {
        await Future.delayed(Duration(seconds: 5)).then((_) async {
          return await platform.invokeMethod('getSensorValue');
        }).then(
          (sensorValues) {
            this.grade = Grade.withSensorValues(sensorValues);
            setState(() {
              _sensorValues = sensorValues;
              widget.isLoading = false;
            });
          },
        );
      });
    } on PlatformException catch (e) {
      print("Failed to get sensor values: '${e.message}'.");
    }
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
          title: Text(
            "watch intro",
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: Colors.deepOrange,
                    child: Text(
                      'DONATE!',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: widget.isLoading
                        ? createCircularSliderForLoading()
                        : createCircularSlider(),
//                        ? Text("LOADING!")
//                        : Text(_sensorValues),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'Calibrate: ${values.irValue}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor:
                        _calibrationOk(double.parse(values.irValue))
                            ? Colors.green
                            : Colors.red,
                  )
//                  Text('RedValue: ${values.redValue}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Get Sensor Values',
                      style: TextStyle(color: Colors.white),
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

  bool _calibrationOk(double value) {
    if (8000 < value && value < 12000) {
      return true;
    } else
      return false;
  }

  Widget createCircularSliderForLoading() {
    return SleekCircularSlider(
      appearance: getCircularAppearanceForLoading(),
      initialValue: 9,
      innerWidget: (double value) {
        return Center(
          child: Text(
            'Loading...',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
      },
    );
  }

  Widget createCircularSlider() {
    return SleekCircularSlider(
      appearance: getCircularAppearance(),
      initialValue: double.parse(grade.grade),
      min: 0.0,
      max: 10.0,
      innerWidget: (double value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                grade.grade,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              Text("Grade",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
            ],
          ),
        );
      },
    );
  }

  CircularSliderAppearance getCircularAppearance() {
    return CircularSliderAppearance(
      customWidths: CustomSliderWidths(
        trackWidth: 1,
        progressBarWidth: 5,
        shadowWidth: 15,
      ),
      customColors: CustomSliderColors(
        dotColor: Colors.white,
        trackColor: Colors.blue.withOpacity(0.6),
        progressBarColors: [
          Colors.green.withOpacity(1),
          Colors.green.withOpacity(1),
          Colors.red.withOpacity(0.8),
          Colors.red.withOpacity(0.8),
        ],
        hideShadow: true,
        shadowColor: Colors.blue,
        shadowMaxOpacity: 0.07,
      ),
      size: 250.0,
    );
  }

  CircularSliderAppearance getCircularAppearanceForLoading() {
    return CircularSliderAppearance(
      customWidths: CustomSliderWidths(
        trackWidth: 1,
        progressBarWidth: 5,
        shadowWidth: 15,
      ),
      customColors: CustomSliderColors(
        dotColor: Colors.white,
        trackColor: Colors.blue.withOpacity(0.6),
        progressBarColors: [
          Colors.red.withOpacity(0.8),
          Colors.green.withOpacity(0.5),
        ],
        shadowColor: Colors.green,
        shadowMaxOpacity: 0.07,
      ),
      size: 100.0,
      spinnerMode: true,
      spinnerDuration: 1500,
    );
  }
}
