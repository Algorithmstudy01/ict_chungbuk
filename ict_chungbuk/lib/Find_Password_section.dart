import 'package:flutter/material.dart';
import 'login_section.dart'; // Import the Login section

class FindPasswordSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: '이메일을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle password finding logic
                },
                child: Text(
                  'PW 찾기',
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                    fontSize: 18, // Set font size to 18
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  minimumSize: Size(double.infinity, 50), // Full-width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to Login section
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSection()),
                  );
                },
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
