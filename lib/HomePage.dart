import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = "";
  
  void initState(){
    super.initState();
    loadCamera();
    loadmodel();
  }

  loadCamera(){
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController!.initialize().then((value){
      if(!mounted){
        return;
      }
      else{
        setState(() {
          cameraController!.startImageStream((ImageStream) => {
            cameraImage = ImageStream,
            runModel(),
          });
        });
      }
    });
  }

  runModel()async{
    if(CameraImage!=null){
      var prediction = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane){
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      prediction!.forEach((element) {
        setState(() {
          output = element["label"];
        });
      });
    }
  }

  loadmodel()async{
    await Tflite.loadModel(
      model: "assets/keypoint_classifier.tflite",
      labels: "assets/keypoint_classifier_label.csv",
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Hand Gesture Camera"),
          backgroundColor: Colors.purple,
        ),
        body: Column(children: [
          Padding(padding: EdgeInsets.all(20),
          child:Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width,
            child: (!cameraController!.value.isInitialized)?Container():AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(cameraController!),
            ),
          )
      ),
       Text("needed action: right open",
        style: TextStyle(
          background: Paint()..color = Colors.white,
          fontSize: 20,
          color: Colors.black,
        ),
       ),
       Text("your action: $output",
        style: TextStyle(
          background: Paint()..color = Colors.white,
          fontSize: 20,
          color: Colors.black,
        ),
       ),
      ]),
      ),
    );
  }
}