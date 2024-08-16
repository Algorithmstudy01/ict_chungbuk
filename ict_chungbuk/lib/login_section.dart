import 'package:flutter/material.dart';
import 'homepage.dart';
import 'Find_Id_section.dart'; // Import the Find ID section
import 'Find_Password_section.dart'; // Import the Find Password section
import 'signup_section.dart'; // Import the SignUp section

class LoginSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: '비밀번호 ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the homepage on login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300], // Set the button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Round the edges of the button
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                '로그인',
                style: TextStyle(
                  color: Colors.white, // Change text color to white
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    // Navigate to Find ID section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindIDSection()),
                    );
                  },
                  child: Text(
                    'ID 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    // Navigate to Find Password section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordSection()),
                    );
                  },
                  child: Text(
                    'PW 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    // Navigate to Sign Up section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpSection()),
                    );
                  },
                  child: Text(
                    '회원가입',
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
