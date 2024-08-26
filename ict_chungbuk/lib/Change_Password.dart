import 'package:flutter/material.dart';
import 'login_section.dart'; // Import the Login Screen

class PasswordChangeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: Text('비밀번호 변경'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align the column at the top
          children: [
            SizedBox(height: 150), // Add space at the top if needed
            _buildPasswordField(
              labelText: '현재 비밀번호',
              hintText: '비밀번호를 입력해 주세요.',
            ),
            SizedBox(height: 12), // Reduce the space between fields
            _buildPasswordField(
              labelText: '새로운 비밀번호',
              hintText: '비밀번호를 입력해 주세요.',
            ),
            SizedBox(height: 12), // Reduce the space between fields
            _buildPasswordField(
              labelText: '새로운 비밀번호 확인',
              hintText: '비밀번호를 입력해 주세요.',
            ),
            SizedBox(height: 32), // Reduce space before the button
            ElevatedButton(
              onPressed: () {
                // Navigate to the message screen before login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordChangeCompleteScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200], // 버튼 색상
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              ),
              child: Text(
                '비밀번호 변경',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({required String labelText, required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        PasswordField(hintText: hintText),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  final String hintText;

  PasswordField({required this.hintText});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
    );
  }
}

class PasswordChangeCompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Automatically navigate to the login screen after a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.popUntil(
        context,
        (route) => route.isFirst, // Navigate to the LoginScreen
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '비밀번호가 변경되었습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '로그인창으로 이동합니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
