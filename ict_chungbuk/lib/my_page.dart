import 'package:flutter/material.dart';

import 'Change_Password.dart'; // 비밀번호 변경 페이지
import 'Membership_Withdrawal.dart'; // 회원탈퇴 페이지
import 'Family_Registration.dart'; // 가족 등록 페이지

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pill_information.dart'; // 알약 정보 페이지
import 'package:chungbuk_ict/search_history_screen.dart';

class MyPage extends StatefulWidget {
  final String userId;

  const MyPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '';

  late String _userId = widget.userId; // userId 할당

  @override
  void initState() {
    super.initState();
    _userId = widget.userId; // Initialize _userId here
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final response =
    await http.get(Uri.parse('http://10.0.2.2:8000/user_info/$_userId'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _nickname = data['nickname'] ?? ''; // null 체크 및 기본값 설정

      });
      print(_nickname);
    } else {
      // 에러 처리
      print('Failed to load user info');
    }
  }

  void openPillInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchHistoryScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Container(
        color: Colors.white, // Set background color to white
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[50],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "안녕하세요.",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "$_nickname 님",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),

            ListTile(
              title: Text("검색 기록"),
              trailing: Icon(Icons.chevron_right),
              onTap: openPillInformation, // Updated to call the correct function
            ),
            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),

            ListTile(
              title: Text("비밀번호 변경"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePW(userId: widget.userId)),
                );
              },
            ),

            ListTile(
              title: Text("가족 등록하기"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 가족 등록하기 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyRegister(userId: widget.userId)), // Added Family Registration navigation
                );
              },
            ),
            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),
            ListTile(
              title: Text("회원탈퇴"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 회원탈퇴 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MembershipWithdrawScreen(userId: widget.userId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
