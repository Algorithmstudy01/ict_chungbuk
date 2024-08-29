import 'package:flutter/material.dart';
import 'login_section.dart';
import 'signup_section.dart';

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
              // Logo image
              Image.asset(
                'assets/img/logo.jpg', // Replace with your image asset path
                width: 300,
                height: 300,
              ),
              SizedBox(height: 40), // Space between image and buttons

              // SizedBox to ensure consistent button width
              SizedBox(
                width: 250, // Set the desired width for all buttons
                child: Column(
                  children: [
                    // Login button with image only
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginSection()),
                        );
                      },
                      child: Image.asset(
                        'assets/img/login_button.png', // Use the correct path to your image
                        width: 250, // Adjust the width as needed
                        fit: BoxFit.contain, // Ensure the image scales correctly
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sign Up button with image only
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpSection()),
                        );
                      },
                      child: Image.asset(
                        'assets/img/signup_button.png', // Use the correct path to your image
                        width: 250, // Adjust the width as needed
                        fit: BoxFit.contain, // Ensure the image scales correctly
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
