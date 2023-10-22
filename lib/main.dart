import 'package:camera/camera.dart';
import 'package:egadun/views/camera_view.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(EgadunCam(cameras: cameras));
}

class EgadunCam extends StatelessWidget {
  final List<CameraDescription> cameras;

  const EgadunCam({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Camera App', home: CameraView());
  }
}
