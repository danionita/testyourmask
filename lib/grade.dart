import 'package:flutter/foundation.dart';

class Grade with ChangeNotifier {
  String grade;

  Grade(){
    this.grade = '0.0';
  }


  Grade.withSensorValues(String sensorValues) {
    _computeGrade(sensorValues);
    notifyListeners();
  }

  void _computeGrade(String sensorValues) {
    List<String> ss = sensorValues.split('\nLED_IR, ');
    int length2 = 'LED_RED, '.length;
    List<String> redValues =
        ss[0].substring(ss[0].indexOf('LED_RED, ') + length2).split(', ');
    List<String> irValues = ss[1].split(', ');
    List<double> red = List<double>();
    List<double> ir = List<double>();

    redValues.forEach((s) => red.add(double.parse(s)));
    irValues.forEach((s) => ir.add(double.parse(s)));

    var doubleIr =
        ir.reduce((a, b) => a + b) / ir.length / 40000; //TODO calibration
    var doubleRed =
        red.reduce((a, b) => a + b) / red.length / 40000; //TODO calibration
    var gradeIr = doubleIr.toStringAsFixed(1);
    var gradeRed = doubleRed.toStringAsFixed(1);
    this.grade = gradeIr;
  }


}
