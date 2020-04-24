package com.example.testyourmask;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import java.util.Arrays;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rocinante.tym/battery";

    SensorManager sm = null;
    private List<Sensor> list;
    float[] values = null;
    SensorEventListener sel = new SensorEventListener() {
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }

        public void onSensorChanged(SensorEvent event) {
            values = event.values;
            String msg = "PPG " + (int) event.values[0];
            System.out.println(msg);
        }
    };
//
//    @Override
//    public void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        sm = (SensorManager) getSystemService(SENSOR_SERVICE);
//
//        List<Sensor> allSensors = sm.getSensorList(Sensor.TYPE_ALL);
//        System.out.println(allSensors);
//
//        Sensor hrmLedIr = sm.getDefaultSensor(65571);
//        Sensor hrmLedRed = sm.getDefaultSensor(65572);
//        Sensor hrmSensor = sm.getDefaultSensor(65562);
//        Sensor hrSensor = sm.getDefaultSensor(21);
//        list = Arrays.asList(hrmLedIr, hrmLedRed, hrmSensor, hrSensor);
//
//        for (Sensor s : list) {
//            sm.registerListener(sel, s, SensorManager.SENSOR_DELAY_FASTEST);
//        }
//    }

    @Override
    protected void onStop() {
        if (list.size() > 0) {
            sm.unregisterListener(sel);
        }
        super.onStop();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();

                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else if (call.method.equals("getSensorValue")) {
                                if (values != null) {
                                    result.success(Arrays.toString(values));
                                } else {
                                    result.error("UNAVAILABLE", "NO VALUES available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        return batteryLevel;
    }






    SensorEventListener accelerometerListener = new SensorEventListener() {
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }

        public void onSensorChanged(SensorEvent event) {
            values = event.values;
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        sm = (SensorManager) getSystemService(SENSOR_SERVICE);
        list = sm.getSensorList(Sensor.TYPE_ACCELEROMETER);
        if (list.size() > 0) {
            sm.registerListener(accelerometerListener, list.get(0), SensorManager.SENSOR_DELAY_NORMAL);
        }
    }

}
