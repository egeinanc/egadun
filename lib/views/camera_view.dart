import 'package:camera/camera.dart';
import 'package:egadun/controller/scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInit.value
                ? Stack(
                    children: [
                      CameraPreview(controller.controller),
                      Positioned(
                        width: controller.w,
                        height: controller.h,
                        top: controller.x,
                        left: controller.y,
                        child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.green, width: 4.0)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  color: Colors.white,
                                  child: Text(controller.label)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : const Center(child: Text("Loading..."));
          }),
    );
  }
}