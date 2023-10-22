import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController controller;
  var isCameraInit = false.obs;
  late List<CameraDescription> cameras;

  var cameraCount = 0;

  var x, y, w, h = 0.0;
  var label = "";

  @override
  void onInit() {
    super.onInit();
    initCamera(0);
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
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
          objectDetector(image); // todo A resource failed to call destroy.
        }
        update();
      });

      isCameraInit(true);
    } else {
      print("Permission denied");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false);
  }

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
        threshold: 0.4);

    if (detector!.isNotEmpty) {
      label = "$detector";
      h = 100.0;
      w = 200.0;
      x = 25.0;
      y = 50.0;
    }
  }
}
