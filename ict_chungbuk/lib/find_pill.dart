import 'dart:convert';
import 'dart:io';
import 'package:chungbuk_ict/pill_information.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Camera.dart';

class PillInfo {
  final String pillCode;
  final String pillName;
  final String confidence;
  final String efficacy;
  final String manufacturer;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;

  PillInfo({
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.efficacy,
    required this.manufacturer,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'pillCode': pillCode,
      'pillName': pillName,
      'confidence': confidence,
      'usage': usage,
      'precautionsBeforeUse': precautionsBeforeUse,
      'usagePrecautions': usagePrecautions,
      'drugFoodInteractions': drugFoodInteractions,
      'sideEffects': sideEffects,
      'storageInstructions': storageInstructions,
      'efficacy': efficacy,
      'manufacturer': manufacturer,
    };
  }

  factory PillInfo.fromJson(Map<String, dynamic> json) {
    return PillInfo(
      pillCode: json['pillCode'] ?? 'Unknown',
      pillName: json['pillName'] ?? 'Unknown',
      confidence: json['confidence'] ?? 'Unknown',
      usage: json['usage'] ?? 'No information',
      precautionsBeforeUse: json['precautionsBeforeUse'] ?? 'No information',
      usagePrecautions: json['usagePrecautions'] ?? 'No information',
      drugFoodInteractions: json['drugFoodInteractions'] ?? 'No information',
      sideEffects: json['sideEffects'] ?? 'No information',
      storageInstructions: json['storageInstructions'] ?? 'No information',
      efficacy: json['efficacy'] ?? 'No information',
      manufacturer: json['manufacturer'] ?? 'No information',
    );
  }
}

class FindPill extends StatefulWidget {
  final String userId;

  const FindPill({Key? key, required this.userId}) : super(key: key);

  @override
  State<FindPill> createState() => _FindPillState();
}

class _FindPillState extends State<FindPill> with AutomaticKeepAliveClientMixin {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  XFile? _image;
  bool _isLoading = false;
  Map<String, dynamic> _pillInfo = {};

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pillInfo = {};
    _initializeCamera();
  }

  void _initializeCamera() {
    final Cameras = Provider.of<Camera>(context, listen: false);
    _cameras = Cameras.cameras;
    if (_cameras.isNotEmpty) {
      controller = CameraController(
        _cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

    }
    controller.initialize().then((_) {
      // 카메라가 작동되지 않을 경우
      if (!mounted) {
        return;
      }
      // 카메라가 작동될 경우
      setState(() {
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
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _pillInfo = {};
      });
    }
  }

  Future<void> _startSearch() async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      await _uploadImage(File(_image!.path));
    } else {
      _showErrorDialog('이미지를 먼저 선택해 주세요.');
    }
  }

 Future<void> _uploadImage(File image) async {
  final url = Uri.parse('http://10.0.2.2:8000/predict/');

  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('image', image.path));

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);

      if (decodedData.isEmpty || !decodedData.containsKey('pill_code')) {
        _showErrorDialog('사진을 다시 촬영해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
        setState(() {
          _pillInfo = decodedData;
          _isLoading = false;
        });

        final pillInfo = PillInfo.fromJson(_pillInfo);
        await _saveSearchHistory(pillInfo);

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
              efficacy: _pillInfo['efficacy'] ?? 'No information',
              manufacturer: _pillInfo['manufacturer'] ?? 'No information',
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

  Future<void> _saveSearchHistory(PillInfo pillInfo) async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/save_search_history/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'prediction_score': pillInfo.confidence,
        'product_name': pillInfo.pillName,
        'manufacturer': pillInfo.manufacturer,
        'pill_code': pillInfo.pillCode,
        'efficacy': pillInfo.efficacy,
        'usage': pillInfo.usage,
        'precautions_before_use': pillInfo.precautionsBeforeUse,
        'usage_precautions': pillInfo.usagePrecautions,
        'drug_food_interactions': pillInfo.drugFoodInteractions,
        'side_effects': pillInfo.sideEffects,
        'storage_instructions': pillInfo.storageInstructions,
      }),
    );

    if (response.statusCode == 200) {
      print('Search history saved successfully.');
    } else {
      print('Failed to save search history. Status code: ${response.statusCode}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('오류'),
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
  void dispose() {
    controller.dispose();
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0), // 상하 여백을 추가합니다. (좌우 여백도 필요하다면 EdgeInsets.all() 등을 사용할 수 있습니다.)
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text(
                                '알약 검색 중입니다...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
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
               Column(
  children: [
    GestureDetector(
                          onTap: controller.value.isInitialized ? _takePicture : null,
                          child: Image.asset(
                            'assets/img/camera.png', // Use the correct path to your image
                            width: 335, // Adjust the width as needed
                            height: 56,
                            fit: BoxFit.contain, // Ensure the image scales correctly
                          ),
                        ),

                        SizedBox(height: 16), // 버튼 사이의 여백을 추가합니다. 이 값을 조정하여 원하는 공간을 설정할 수 있습니다.
                        GestureDetector(
                          onTap: _startSearch,
                          child: Image.asset(
                            'assets/img/search.png', // Use the correct path to your image
                            width: 335, // Adjust the width as needed
                            height: 56,
                            fit: BoxFit.contain, // Ensure the image scales correctly
                          ),
                        ),
  ],
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
        ),
      );
}

  @override
  bool get wantKeepAlive => true;
}





 // PillInfo 클래스를 정의한 파일을 가져와야 합니다.

class ImageUploadScreen extends StatefulWidget {
  final String userId;

  const ImageUploadScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  bool _isLoading = false;
  late Map<String, dynamic> _pillInfo;
Future<void> _uploadImage(File image) async {
  final url = Uri.parse('http://10.0.2.2:8000/predict/');

  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('image', image.path));

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);

      if (decodedData.isEmpty || !decodedData.containsKey('pill_code')) {
        _showErrorDialog('사진을 다시 촬영해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _pillInfo = decodedData;
        _isLoading = false;
      });

      final pillInfo = PillInfo.fromJson(_pillInfo);
      await _saveSearchHistory(pillInfo);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InformationScreen(
            pillCode: pillInfo.pillCode,
            pillName: pillInfo.pillName,
            confidence: pillInfo.confidence,
            userId: widget.userId,
            usage: pillInfo.usage,
            precautionsBeforeUse: pillInfo.precautionsBeforeUse,
            usagePrecautions: pillInfo.usagePrecautions,
            drugFoodInteractions: pillInfo.drugFoodInteractions,
            sideEffects: pillInfo.sideEffects,
            storageInstructions: pillInfo.storageInstructions,
            efficacy: pillInfo.efficacy,
            manufacturer: pillInfo.manufacturer,
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
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSearchHistory(PillInfo pillInfo) async {
    // 검색 기록 저장 로직 구현 필요
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 업로드'),
      ),
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Text('이미지 업로드 화면'),
      ),
    );
  }
}
