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
  final String userId;  // Add this line

  const FindPill({super.key, required this.userId});  // Modify this line


  @override
  State<FindPill> createState() => _FindPill();
}

class _FindPill extends State<FindPill> with AutomaticKeepAliveClientMixin {
  late CameraController controller;
  XFile? _image; // Variable to store the image
  bool _isLoading = false; // Flag to track loading state
  String _pillCode = '';
  String _pillName = '';
  String _confidence = '';
  String _extractedText = '';

  final ImagePicker picker = ImagePicker(); // Initialize ImagePicker

  // Function to pick image from the gallery or camera
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); // Store the picked image
        _pillCode = '';      // Reset values for new image
        _pillName = '';
        _confidence = '';
        _extractedText = '';
        _isLoading = true;   // Start loading
      });

      await _uploadImage(File(pickedFile.path)); // Upload the image
    }
  }

  // Function to take a picture using the camera
  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }
    try {
      final XFile file = await controller.takePicture();
      setState(() {
        _image = file;
        _pillCode = '';      // Reset values for new image
        _pillName = '';
        _confidence = '';
        _extractedText = '';
        _isLoading = true;   // Start loading
      });

      await _uploadImage(File(file.path)); // Upload the image
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  // Function to upload the image
  Future<void> _uploadImage(File image) async {
    final url = Uri.parse('http://10.0.2.2:8000/predict/'); // Ensure this URL is correct

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setState(() {
          final pillInfo = decodedData['pill_info'];
          _pillCode = pillInfo['code'] ?? 'Unknown';
          _pillName = pillInfo['name'] ?? 'Unknown';
          _confidence = decodedData['confidence']?.toString() ?? 'Unknown';
          _extractedText = decodedData['extracted_text']?.toString() ?? 'No text found';
          _isLoading = false; // Stop loading
        });

        // Navigate to the InformationScreen with the extracted pill details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InformationScreen(
              pillCode: _pillCode,
              pillName: _pillName,
              confidence: _confidence,
              extractedText: _extractedText,
              userId: widget.userId,
            ),
          ),
        );
      } else {
        _showErrorDialog(); // Show error dialog on failure
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      _showErrorDialog(); // Show error dialog on exception
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Function to show an error dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('인식 실패'),
          content: Text('사진을 다시 촬영해주세요 \n또는 사진을 다시 선택해주세요.'),
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
    final Cameras = Provider.of<Camera>(context, listen: false);

    // Ensure that the camera list is initialized before accessing
    if (Cameras.cameras.isNotEmpty) {
      // Initialize the camera controller
      controller = CameraController(
        Cameras.cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          // Camera is initialized and ready to use
        });
      }).catchError((Object e) {
        if (e is CameraException) {
          print("CameraController Error: ${e.code}");
        }
      });
    } else {
      print("No cameras available");
    }
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose the camera controller
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
        elevation: 4, // Add shadow to the AppBar
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
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
                    padding: EdgeInsets.all(20.0), // Add padding around the image display area
                    child: SizedBox(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loading indicator if loading
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
                      onPressed: controller.value.isInitialized ? _takePicture : null, // Only enable when camera is initialized
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC42AFA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '촬영하기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Manrope',
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
