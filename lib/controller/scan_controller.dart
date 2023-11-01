import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController controller;
  var isCameraInit = false.obs;
  var isObjectFound = false.obs;
  late List<CameraDescription> cameras;

  var cameraCount = 0;

  var x, y, w, h = 0.0;
  var label = "";
  List<String> debugLabel = [];

  late Size size;

  ScanController(this.size);

  @override
  void onInit() {
    super.onInit();
    initCamera(0);
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    controller.stopImageStream();
    controller.dispose();
  }

  initCamera(int cameraIndex) async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      controller = CameraController(
          cameras[cameraIndex], ResolutionPreset.veryHigh,
          enableAudio: false);

      await controller.initialize();

      controller.startImageStream((image) {
        cameraCount++;
        if (cameraCount % 10 == 0) {
          cameraCount = 0;
          runModelOnFrame(image); // todo A resource failed to call destroy.
        }
        update();
      });

      isCameraInit(true);
    } else {
      print("Permission denied");
    }
  }

  initTFLite() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/yolov2_tiny.tflite",
      labels: "assets/yolov2_tiny.txt",
    );
  }

  //YOLOv2-Tiny
  runModelOnFrame(CameraImage image) async {
    isObjectFound(true);

    var detectedObjects = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((e) => e.bytes).toList(),
        model: "YOLO",
        imageHeight: image.height,
        imageWidth: image.width,
        numResultsPerClass: 10,
        threshold: 0.4);

    if (detectedObjects!.isNotEmpty) {
      var detectedObject = detectedObjects.first;

      var showSquare = detectedObject["confidenceInClass"] * 100 > 1;

      if (showSquare) {
        debugLabel = detectedObjects
            .map((detectedObject) =>
                """${detectedObject["detectedClass"]} ${cutDecimals(detectedObject["confidenceInClass"] * 100)}""")
            .toList();

        label = """""";
        h = detectedObject["rect"]["h"] * size.height;
        w = detectedObject["rect"]["w"] * size.width;
        x = detectedObject["rect"]["x"] * size.width;
        y = detectedObject["rect"]["y"] * size.height;
      }
      isObjectFound(showSquare);
    }
  }

  cutDecimals(double d) {
    return d.toStringAsPrecision(3);
  }

  @Deprecated("Replaced by runModelOnFrame()")
  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e) => e.bytes).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        rotation: 90,
        threshold: 0.0);

    if (detector!.isNotEmpty) {
      var showSquare = detector.first["confidence"] * 100 > 50;
      if (showSquare) {
        label = "$detector";
        h = 400.0;
        w = 200.0;
        x = 25.0;
        y = 50.0;
      }
      isObjectFound(showSquare);
    }
  }
}
