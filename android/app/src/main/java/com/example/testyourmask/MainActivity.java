package com.example.testyourmask;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.SensorManager;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.samsung.android.sdk.SsdkUnsupportedException;
import com.samsung.android.sdk.sensorextension.Ssensor;
import com.samsung.android.sdk.sensorextension.SsensorEvent;
import com.samsung.android.sdk.sensorextension.SsensorEventListener;
import com.samsung.android.sdk.sensorextension.SsensorExtension;
import com.samsung.android.sdk.sensorextension.SsensorManager;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rocinante.tym/battery";
    Map<String, String> sensorToValues = new HashMap<>();
    List<String> hrmIrValues;
    List<String> hrmRedValues;


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
                            if (call.method.equals("fetchValues")) {
                                hrmIrValues = new ArrayList<>();
                                hrmIrValues.add("Starting Now");
                                hrmRedValues = new ArrayList<>();
                                hrmRedValues.add("Starting now");
                            }
                            if (call.method.equals("getSensorValue")) {
                                if (sensorToValues != null) {
                                    sensorToValues.put("LED_IR: ", hrmIrValues.toString());
                                    sensorToValues.put("LED_RED: ", hrmRedValues.toString());
                                    String result1 = sensorToValues.toString();
                                    writeToFile(result1);
                                    System.out.println("===> " + result1);
                                    result.success(result1);
                                } else {
                                    result.error("UNAVAILABLE", "NO VALUES available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    SsensorEventListener ssensorEventListener = new SsensorEventListener() {
        @Override
        public void OnSensorChanged(SsensorEvent ssensorEvent) {
            Ssensor sensor = ssensorEvent.sensor;
            switch (sensor.getType()) {
                case Ssensor.TYPE_HRM_LED_IR: {
                    if (hrmIrValues != null) {
                        hrmIrValues.add(String.valueOf(ssensorEvent.values[0]));
                    }
                    break;
                }
                case Ssensor.TYPE_HRM_LED_RED: {
                    if (hrmRedValues != null) {
                        hrmRedValues.add(String.valueOf(ssensorEvent.values[0]));
                    }
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

    private void writeToFile(String data) {
        try {
            Context context = this.getApplicationContext();
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("data.txt", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        } catch (IOException e) {
            System.out.println("Exception: File write failed: " + e.toString());
        }
    }
}