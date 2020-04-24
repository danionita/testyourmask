package com.example.testyourmask;

import android.Manifest;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.samsung.android.sdk.SsdkUnsupportedException;
import com.samsung.android.sdk.sensorextension.Ssensor;
import com.samsung.android.sdk.sensorextension.SsensorEvent;
import com.samsung.android.sdk.sensorextension.SsensorEventListener;
import com.samsung.android.sdk.sensorextension.SsensorExtension;
import com.samsung.android.sdk.sensorextension.SsensorManager;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rocinante.tym/battery";
    Map<String, String> sensorToValues = new HashMap<>();


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SsensorExtension ssensorExtension = new SsensorExtension();
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.BODY_SENSORS)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.BODY_SENSORS},
                    1);
        }

        try {
            ssensorExtension.initialize(this);
        } catch (SsdkUnsupportedException e) {
            e.printStackTrace();
        }
        SsensorManager ssensorManager = new SsensorManager(this, ssensorExtension);
        Ssensor hrmIr = ssensorManager.getDefaultSensor(SsensorExtension.TYPE_HRM_LED_IR);
//        Ssensor hrmGreen = ssensorManager.getDefaultSensor(SsensorExtension.TYPE_HRM_LED_GREEN);
        Ssensor hrmRed = ssensorManager.getDefaultSensor(SsensorExtension.TYPE_HRM_LED_RED);
//        Ssensor hrmBlue = ssensorManager.getDefaultSensor(SsensorExtension.TYPE_HRM_LED_BLUE);
        ssensorManager.registerListener(ssensorEventListener, hrmIr, SensorManager.SENSOR_DELAY_NORMAL);
        ssensorManager.registerListener(ssensorEventListener, hrmRed, SensorManager.SENSOR_DELAY_NORMAL);
    }

    @Override
    protected void onStop() { //TODO stop sensors
//        if (list.size() > 0) {
//            sm.unregisterListener(sel);
//        }
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
                                if (sensorToValues != null) {
                                    result.success(sensorToValues.toString());
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


//    SensorEventListener accelerometerListener = new SensorEventListener() {
//        public void onAccuracyChanged(Sensor sensor, int accuracy) {
//        }
//
//        public void onSensorChanged(SensorEvent event) {
//            values = event.values;
//        }
//    };
//
//    @Override
//    public void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        sm = (SensorManager) getSystemService(SENSOR_SERVICE);
//        list = sm.getSensorList(Sensor.TYPE_ACCELEROMETER);
//        if (list.size() > 0) {
//            sm.registerListener(accelerometerListener, list.get(0), SensorManager.SENSOR_DELAY_NORMAL);
//        }
//    }

    SsensorEventListener ssensorEventListener = new SsensorEventListener() {
        @Override
        public void OnSensorChanged(SsensorEvent ssensorEvent) {
            Ssensor sensor = ssensorEvent.sensor;
            switch (sensor.getType()) {
                case Ssensor.TYPE_HRM_LED_IR: {
                    sensorToValues.put("LED_IR: ", Arrays.toString(ssensorEvent.values));
                    break;
                }
                case Ssensor.TYPE_HRM_LED_RED: {
                    sensorToValues.put("LED_RED: ", Arrays.toString(ssensorEvent.values));
                    break;
                }
                default: {
                    System.out.println("SSS");
                    break;
                }
            }
        }

        @Override
        public void OnAccuracyChanged(Ssensor ssensor, int i) {

        }
    };
}