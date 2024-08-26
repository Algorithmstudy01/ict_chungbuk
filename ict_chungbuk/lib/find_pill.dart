import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'Camera.dart';

class FindPill extends StatefulWidget{


  const FindPill({super.key});

  @override
  State<FindPill> createState() => _FindPill();
}

class _FindPill extends State<FindPill> with AutomaticKeepAliveClientMixin{
  late CameraController controller;
  late List<CameraDescription> _cameras;
  XFile? _image; //이미지를 담을 변수 선언
  late bool condition = false;

  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        condition = false;
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }
   
  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }
    try {
      // 사진 촬영
      final XFile file = await controller.takePicture();
      _image = file;
      setState(() {
        condition = false;
      });

    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> upload() async {
    setState(() {
      condition = true;
    });
  }

  @override
  void initState() {
    final Cameras = Provider.of<Camera>(context, listen: false);
    _cameras = Cameras.cameras;
    super.initState();
    // 카메라 컨트롤러 초기화
    // _cameras[0] : 사용 가능한 카메라
    controller =
        CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false);

    controller.initialize().then((_) {
      // 카메라가 작동되지 않을 경우
      if (!mounted) {
        condition = false;
        return;
      }
      // 카메라가 작동될 경우
      setState(() {
        condition = true;
      });
    })
    // 카메라 오류 시
        .catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("CameraController Error : CameraAccessDenied");
            // Handle access errors here.
            break;
          default:
            print("CameraController Error");
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    // 카메라 컨트롤러 해제
    // dispose에서 카메라 컨트롤러를 해제하지 않으면 에러 가능성 존재
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // 카메라 컨트롤러가 초기화 되어 있지 않을 경우, 카메라 뷰 띄우지 않음
    if (!controller.value.isInitialized) {
      condition = false;
    }
    // 카메라 촬영 화면
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('알약 검색'),
          backgroundColor: Colors.white,
          elevation: 4, // Add shadow to the AppBar
          centerTitle: true,
          foregroundColor: Colors.black,
          shadowColor: Colors.grey.withOpacity(0.5),// Set shadow color
          automaticallyImplyLeading: false,
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: size.width*0.4,
              height: size.height*0.04,
              child: const Text(
                '알약 촬영하기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  height: 0,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: size.width*0.8,
                  height: size.height*0.06,
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '정확한 알약 확인을 위해 사진을 준비해 주세요.\n아래의 ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: '촬영하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: ' 버튼을 눌러 사진을 찍어주세요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: size.width*0.8,
                  height: size.width*0.8,
                  child: ((){
                    if(condition){
                      return CameraPreview(controller);
                    }
                    else {
                      if(_image != null){
                        return Image.file(File(_image!.path),fit: BoxFit.cover,);
                      }
                      else {
                        return Container(
                          color: Colors.grey,
                        );
                      }
                    }
                  }
                  )(),
                ) ,
                SizedBox(
                  width: size.width*0.8,
                  height: size.height*0.06,
                  child: const Text(
                    '사진을 촬영, 등록하면, 위의 그림과 같이 텍스트를 \n인식하여 자동으로 알약의 정보를 불러옵니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4F4F4F),
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: 335,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: condition ? _takePicture : upload,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC42AFA),
                        shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(10))
                    ),
                    child: Text(condition ? '촬영하기' : '등록하기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                        height: 0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 335,
                  height: 56,
                  child: TextButton
                    (onPressed: condition?(){getImage(ImageSource.gallery);}:(){setState((){condition=true;});},
                      child: Text(
                        condition ? '갤러리에서 사진 가져오기' : '다른 사진 등록하기',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          height: 0,
                        ),
                      )
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

