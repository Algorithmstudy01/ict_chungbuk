import 'package:flutter/material.dart';
import 'Find_Password_section.dart'; // Import the Find Password section
import 'login_section.dart'; // Import the Login section

class FindIDSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle ID finding logic here
              },
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
