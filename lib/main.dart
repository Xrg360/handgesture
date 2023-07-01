import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand_gesture_cam/HomePage.dart';
import 'package:hand_gesture_cam/WelcomeScreen.dart';
import 'dart:math' as math;
import 'package:tflite/tflite.dart';

List<CameraDescription> cameras = [];

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

