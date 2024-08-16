import 'package:flutter/material.dart';
import 'login_section.dart';
import 'signup_section.dart';
import 'homepage.dart'; // Import the HomePage

class StartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pill icon image
              Image.asset(
                'assets/pill_icon.png', // Replace with your image asset path
                width: 100,
                height: 100,
              ),
              SizedBox(height: 40), // Space between image and buttons

              // SizedBox to ensure consistent button width
              SizedBox(
                width: 250, // Set the desired width for all buttons
                child: Column(
                  children: [
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to HomePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text('시작하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                        fixedSize: Size(250, 50), // Ensures consistent size
                      ),
                    ),
                    SizedBox(height: 16),

                    // Login button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginSection()),
                        );
                      },
                      child: Text('로그인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                        fixedSize: Size(250, 50), // Ensures consistent size
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sign Up button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpSection()),
                        );
                      },
                      child: Text('회원가입'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[300],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                        fixedSize: Size(250, 50), // Ensures consistent size
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
