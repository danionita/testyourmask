package com.example.testyourmask;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.SensorManager;
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

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rocinante.tym/battery";
    List<String> hrmIrValues;
    List<String> hrmRedValues;
    int counter;
    int filecounter =1;
    private MethodChannel methodChannel;


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
        Ssensor hrmRed = ssensorManager.getDefaultSensor(SsensorExtension.TYPE_HRM_LED_RED);
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

        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler(
                (call, result) -> {
                    // Note: this method is invoked on the main thread.
                    if (call.method.equals("fetchValues")) {
                        hrmIrValues = new ArrayList<>();
                        hrmRedValues = new ArrayList<>();
                        counter = 50;
                        result.success(counter);
                    } else if (call.method.equals("getSensorValue")) {
                        if (hrmRedValues != null && hrmIrValues != null) {
                            String data = getData(hrmIrValues, hrmRedValues);
                            writeToFile(data);
                            System.out.println(data);
                            result.success(data);
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
                    methodChannel.invokeMethod("ledIr", ssensorEvent.values[0]);
                    if (hrmIrValues != null && hrmIrValues.size() <= counter) {
                        hrmIrValues.add(String.valueOf(ssensorEvent.values[0]));
                    }
                    break;
                }
                case Ssensor.TYPE_HRM_LED_RED: {
                    methodChannel.invokeMethod("ledRed", ssensorEvent.values[0]);
                    if (hrmRedValues != null && hrmRedValues.size() <= counter) {
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

    private String getData(List<String> hrmIrValues, List<String> hrmRedValues) {
        String irValues = hrmIrValues.toString();
        String redValues = hrmRedValues.toString();
        String red = redValues.substring(redValues.indexOf('[') + 1, redValues.indexOf(']'));
        String ir = irValues.substring(irValues.indexOf('[') + 1, irValues.indexOf(']'));
        return "LED_RED, " + red + '\n' + "LED_IR, " + ir;
    }

    private void writeToFile(String data) {
        try {
            Context context = this.getApplicationContext();
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("data"+filecounter+".csv", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            filecounter+=1;
            outputStreamWriter.close();
        } catch (IOException e) {
            System.out.println("Exception: File write failed: " + e.toString());
        }
    }
}