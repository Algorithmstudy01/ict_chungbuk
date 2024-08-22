import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Find_Password_section.dart'; // Import the Find Password section
import 'login_section.dart'; // Import the Login section

class FindIDSection extends StatefulWidget {
  @override
  _FindIDSectionState createState() => _FindIDSectionState();
}

class _FindIDSectionState extends State<FindIDSection> {
  final TextEditingController _emailController = TextEditingController();
  String _resultMessage = ''; // This will hold the username or error message

  Future<void> _findUserID() async {
    final String email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _resultMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    final url = 'http://10.0.2.2:8000/find_user_id/'; // Replace with your Django endpoint
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = '아이디: ${data['id']}'; // Display the retrieved username
      });
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = data['message'] ?? '일치하는 사용자가 없습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _findUserID, // Attach the ID finding logic
              child: Text(
                '아이디 찾기',
                style: TextStyle(
                  color: Colors.white, // Set text color to white
                  fontSize: 18, // Set font size to 18
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300], // Button color
                minimumSize: Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _resultMessage, // Display the result message or username
              style: TextStyle(
                color: _resultMessage.contains('사용자 이름:') ? Colors.green : Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    // Navigate to Find Password section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordSection()),
                    );
                  },
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}