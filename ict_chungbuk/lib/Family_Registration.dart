import 'package:flutter/material.dart';
import 'my_page.dart'; // Import the MyPage screen

class FamilyRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족등록'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                'Team Logo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 80),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Border color
                    width: 2.0, // Thicker border
                  ),
                ),
                labelText: '이름 입력',
                hintText: '이름을 입력해 주세요.',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Border color
                    width: 2.0, // Thicker border
                  ),
                ),
                labelText: '관계 입력',
                hintText: '관계를 입력해 주세요.',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Border color
                    width: 2.0, // Thicker border
                  ),
                ),
                labelText: '전화번호 입력',
                hintText: '전화번호를 입력해 주세요',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Border color
                    width: 2.0, // Thicker border
                  ),
                ),
                labelText: '주소를 입력해 주세요',
                hintText: '주소를 입력해 주세요',
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyRegisterCompleteScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200], // Background color for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '가족 등록하기',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyRegisterCompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
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
