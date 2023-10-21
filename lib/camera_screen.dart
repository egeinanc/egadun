import 'package:camera/camera.dart';
import 'package:egadun/api/Http.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Future<Response> image;
  int selectedCamera = 0;

  @override
  void initState() {
    initializeCamera(selectedCamera);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  initializeCamera(int cameraIndex) async {
    _controller = CameraController(
        widget.cameras[cameraIndex], ResolutionPreset.veryHigh,
        enableAudio: false);

    _initializeControllerFuture = _controller.initialize();
  }

  Future<Response> _retrieveImageFromApi({bool setNewState = false}) {
    var image = Http.getImageFromApi("https://picsum.photos/200");

    if (setNewState) {
      setState(() {
        this.image = image;
      });
    }
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(children: [
                CameraPreview(_controller),
                FutureBuilder(
                  future: _retrieveImageFromApi(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var response = snapshot.data;
                      return Positioned(
                        left: 100, // X-Position des Rechtecks
                        top: 100, // Y-Position des Rechtecks
                        child: Container(
                          width: 200, // Breite des Rechtecks
                          height: 100, // Höhe des Rechtecks
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            // Hintergrundfarbe des Rechtecks
                            border: Border.all(
                              color: Colors.blue, // Rahmenfarbe
                              width: 2.0, // Rahmenbreite
                            ),
                          ),
                          child: Image.memory(response!.bodyBytes),
                        ),
                      );
                    }
                    return const Text("Loading");
                  },
                ),
              ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _retrieveImageFromApi(setNewState: true),
      ),
    );
  }
}
