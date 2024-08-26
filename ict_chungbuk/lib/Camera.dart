import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera with ChangeNotifier {
  late List<CameraDescription> _cameras;
  Camera(this._cameras);

  List<CameraDescription> get cameras => _cameras;


  void setCameras(newCameras){
    _cameras = newCameras;
    notifyListeners();
  }

  List<CameraDescription> getCameras(){
    return _cameras;
  }
}