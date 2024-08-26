import 'package:flutter/material.dart';
import 'homepage.dart';
import 'Find_Id_section.dart'; // Import the Find ID section
import 'Find_Password_section.dart'; // Import the Find Password section
import 'signup_section.dart'; // Import the SignUp section

class LoginSection extends StatelessWidget {
  const LoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: '비밀번호 ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the homepage on login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TabbarFrame()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300], // Set the button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Round the edges of the button
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(
                  color: Colors.white, // Change text color to white
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  child: const Text(
                    'ID 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    // Navigate to Find Password section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordSection()),
                    );
                  },
                  child: const Text(
                    'PW 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    // Navigate to Sign Up section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpSection()),
                    );
                  },
                  child: const Text(
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
