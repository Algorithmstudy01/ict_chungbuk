import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:chungbuk_ict/pill_information.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      try {
        await controller.initialize();
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        print("CameraController Error: ${e.toString()}");
      }
    } else {
      print("No cameras available");
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

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _pillInfo = {};
        _isLoading = true;
      });

      await _uploadImage(File(pickedFile.path));
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

  Future<void> _saveSearchHistory(PillInfo pillInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = widget.userId;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/save_search_history/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'prediction_score': _pillInfo['prediction_score']?.toString() ?? 'Unknown',
        'product_name': _pillInfo['product_name'] ?? 'Unknown',
        'manufacturer': pillInfo.manufacturer,
        'pill_code':  _pillInfo['pill_code'] ?? 'Unknown',
        'efficacy': pillInfo.efficacy,
        'usage': _pillInfo['usage'] ?? 'No information',
        'precautions_before_use':  _pillInfo['precautions_before_use'] ?? 'No information',
        'usage_precautions':_pillInfo['usage_precautions'] ?? 'No information',
        'drug_food_interactions': _pillInfo['drug_food_interactions'] ?? 'No information',
        'side_effects': _pillInfo['efficacy'] ?? 'No information', // 추가된 부분
        'storage_instructions': _pillInfo['storage_instructions'] ?? 'No information',
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

        setState(() {
          _pillInfo = decodedData;
          _isLoading = false;
        });

        final pillInfo = PillInfo.fromJson(_pillInfo);
        _saveSearchHistory(pillInfo);

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
