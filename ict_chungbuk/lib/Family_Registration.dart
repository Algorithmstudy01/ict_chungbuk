import 'package:chungbuk_ict/my_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamilyRegister extends StatefulWidget {
  final String userId;

  const FamilyRegister({Key? key, required this.userId}) : super(key: key);

  @override
  State<FamilyRegister> createState() => _FamilyRegisterState();
}

class _FamilyRegisterState extends State<FamilyRegister> {
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
Future<void> _submitForm() async {
  final name = _nameController.text;
  final relationship = _relationshipController.text;
  final phoneNumber = _phoneNumberController.text;
  final address = _addressController.text;

  final url = Uri.parse('https://b29d-222-116-163-179.ngrok-free.app/addfamilymember/${widget.userId}/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': name,
      'relationship': relationship,
      'phone_number': phoneNumber,
      'address': address,
    }),
  );

  if (response.statusCode == 201) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyRegisterCompleteScreen(userId: widget.userId),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to register family member: ${response.body}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족등록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/img/logo.jpg', // Update the path to your image
                width: 100, // Adjust the width as needed
                height: 100, // Adjust the height as needed
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '이름 입력',
                hintText: '이름을 입력해 주세요.',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _relationshipController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '관계 입력',
                hintText: '관계를 입력해 주세요.',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '전화번호 입력',
                hintText: '전화번호를 입력해 주세요',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '주소를 입력해 주세요',
                hintText: '주소를 입력해 주세요',
              ),
            ),
            SizedBox(height: 30),
     
        
           GestureDetector(

                 onTap: _submitForm,
              child: Image.asset(
                'assets/img/fam.png', // Use the correct path to your image
                width: 350, // Adjust the width as needed
                fit: BoxFit.contain, // Ensure the image scales correctly
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}

class FamilyRegisterCompleteScreen extends StatelessWidget {
  final String userId;

  FamilyRegisterCompleteScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPage(userId: userId)),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '정상적으로 등록 되었습니다.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
