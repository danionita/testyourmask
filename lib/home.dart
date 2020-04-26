import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testyourmask/values.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';

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
      grade = Grade();
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
  _launchURL() async {
    const url = 'https://ko-fi.com/testyourmask';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                    onPressed: _launchURL,
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
                    child: createCircularSlider(),
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
                    backgroundColor: _calibrationOk(values.irValue)
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
                      'Measure!',
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

  bool _calibrationOk(String valueStr) {
    if (valueStr == null) {
      return false;
    }
    double value = double.parse(valueStr);
    if (8000 < value && value < 12000) {
      return true;
    } else
      return false;
  }

  Widget createCircularSlider() {
    return SleekCircularSlider(
      appearance: circularSliderAppearanceWithoutSpinner,
      min: 0.0,
      max: 10.0,
      initialValue: double.parse(grade.grade),
      innerWidget: (double value) {
        if (!widget.isLoading) {
          return getDisplayValue();
        } else {
          return Align(
            alignment: Alignment.center,
            child: SleekCircularSlider(
              appearance: circularSliderAppearanceWithSpinner,
              min: 0,
              max: 10,
              initialValue: 1,
            ),
          );
        }
      },
    );
  }

  Widget getDisplayValue() {
    return Align(
      alignment: Alignment.center,
      child: Center(
        child: Text(
          'Grade: ${grade.grade}',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

final customColors = CustomSliderColors(
  dotColor: Colors.white.withOpacity(0.8),
  trackColor: HexColor('#98DBFC').withOpacity(0.3),
  progressBarColor: HexColor('#6DCFFF'),
  hideShadow: true,
);

final customResultColors = CustomSliderColors(
  dotColor: Colors.white.withOpacity(0.8),
  trackColor: HexColor('#98DBFC').withOpacity(0.3),
  progressBarColors: [Colors.red, Colors.green],
  gradientStartAngle: 45,
  gradientEndAngle: 360,
  hideShadow: true,
);

final CircularSliderAppearance circularSliderAppearanceWithSpinner =
    CircularSliderAppearance(
  customWidths:
      CustomSliderWidths(trackWidth: 4, progressBarWidth: 10, shadowWidth: 10),
  customColors: customColors,
  startAngle: 90,
  angleRange: 360,
  size: 200,
  spinnerMode: true,
  spinnerDuration: 1500,
);

final CircularSliderAppearance circularSliderAppearanceWithoutSpinner =
    CircularSliderAppearance(
  customWidths:
      CustomSliderWidths(trackWidth: 4, progressBarWidth: 10, shadowWidth: 10),
  customColors: customResultColors,
  startAngle: 90,
  angleRange: 360,
  size: 200,
);

Color HexColor(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
