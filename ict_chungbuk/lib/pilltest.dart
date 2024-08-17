import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final picker = ImagePicker();
  String _prediction = '';
  String _confidence = '';
  String _extractedText = '';
  String _pillName = '';
  String _companyName = '';
  String _classNo = '';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final url = Uri.parse('http://10.0.2.2:8000/predict/'); // 에뮬레이터에서의 주소

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setState(() {
          _prediction = decodedData['prediction'].toString();
          _confidence = decodedData['confidence'].toString();
          _extractedText = decodedData['extracted_text'].toString();
          _pillName = decodedData['pill_name'].toString();
          _companyName = decodedData['company_name'].toString();
          _classNo = decodedData['class_no'].toString();
        });
      } else {
        setState(() {
          _prediction = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Image Upload'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Text('No image selected.')
                  : Container(
                      constraints: BoxConstraints(maxHeight: 300), // 이미지 최대 높이 제한
                      child: Image.file(_image!),
                    ),
              SizedBox(height: 20),
              Text(
                'Prediction: $_prediction',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Confidence: $_confidence',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Extracted Text: $_extractedText',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Pill Name: $_pillName',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Company Name: $_companyName',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                'Class Number: $_classNo',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
