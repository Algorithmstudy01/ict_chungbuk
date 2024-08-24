 import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'Camera.dart';
import 'pill_information.dart';

class FindPill extends StatefulWidget {
  final String userId;

  const FindPill({super.key, required this.userId});

  @override
  State<FindPill> createState() => _FindPill();
}

class _FindPill extends State<FindPill> with AutomaticKeepAliveClientMixin {
  late CameraController controller; // Use late here
  XFile? _image;
  bool _isLoading = false;
  Map<String, dynamic> _pillInfo = {};

  final ImagePicker picker = ImagePicker();

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
        _pillInfo = {};
        _isLoading = true;
      });

      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      print("Camera controller is not initialized.");
      return;
    }
    try {
      final XFile file = await controller.takePicture();
      setState(() {
        _image = file;
        _pillInfo = {};
        _isLoading = true;
      });

      await _uploadImage(File(file.path));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadImage(File image) async {
    final url = Uri.parse('http://10.0.2.2:8000/predict/');

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setState(() {
          _pillInfo = decodedData;
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InformationScreen(
              pillCode: _pillInfo['pill_code'] ?? 'Unknown',
              pillName: _pillInfo['product_name'] ?? 'Unknown',
              confidence: _pillInfo['prediction_score']?.toString() ?? 'Unknown',
              userId: widget.userId,
              usage: _pillInfo['usage'] ?? 'No information',
              precautionsBeforeUse: _pillInfo['precautions_before_use'] ?? 'No information',
              usagePrecautions: _pillInfo['usage_precautions'] ?? 'No information',
              drugFoodInteractions: _pillInfo['drug_food_interactions'] ?? 'No information',
              sideEffects: _pillInfo['side_effects'] ?? 'No information',
              storageInstructions: _pillInfo['storage_instructions'] ?? 'No information',
              efficacy: _pillInfo['efficacy'] ?? 'No information', // 추가된 부분
              manufacturer: _pillInfo['manufacturer'] ?? 'No information', // 추가된 부분
              extractedText: '',
            ),
          ),
        );
      } else {
        _showErrorDialog('서버에서 오류가 발생했습니다.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog('업로드 중 오류가 발생했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('인식 실패'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = Provider.of<Camera>(context, listen: false);

    if (cameras.cameras.isNotEmpty) {
      controller = CameraController(
        cameras.cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      try {
        await controller.initialize();
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        if (e is CameraException) {
          print("CameraController Error: ${e.code}");
          // Optionally show an error dialog or message
        }
      }
    } else {
      print("No cameras available");
      // Optionally show an error dialog or message
    }
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose without null check since it's late
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('알약 검색'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: size.width * 0.8,
                height: size.height * 0.06,
                child: const Text(
                  '알약 촬영하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.09,
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '정확한 알약 확인을 위해 사진을 준비해 주세요.\n아래의 ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: '촬영하기',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: ' 버튼을 눌러 사진을 찍어주세요.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : (_image != null
                              ? Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                )
                              : (controller.value.isInitialized
                                  ? CameraPreview(controller)
                                  : Container(color: Colors.grey))),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.9,
                    height: size.height * 0.09,
                    child: const Text(
                      '사진을 촬영, 등록하면, 위의 그림과 같이 텍스트를 \n인식하여 자동으로 알약의 정보를 불러옵니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        height: 1.5,
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
                      onPressed: controller.value.isInitialized ? _takePicture : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC42AFA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '촬영하기',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 335,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        if (_image == null) {
                          getImage(ImageSource.gallery);
                        } else {
                          setState(() {
                            _image = null; // Clear the current image
                          });
                        }
                      },
                      child: Text(
                        _image == null ? '갤러리에서 사진 가져오기' : '다른 사진 등록하기',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
