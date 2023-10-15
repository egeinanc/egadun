import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(EgadunCam(cameras: cameras));
}

class EgadunCam extends StatelessWidget {
  final List<CameraDescription> cameras;

  const EgadunCam({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      home: CameraScreen(cameras: cameras),
    );
  }
}

