import 'package:flutter/material.dart';
import 'Change_Password.dart'; // 비밀번호 변경 페이지
import 'Membership_Withdrawal.dart'; // 회원탈퇴 페이지
import 'Bookmark.dart'; // 즐겨찾기 페이지
import 'Family_Registration.dart'; // 가족 등록 페이지
import 'alarm.dart'; // 알림 설정 페이지
import 'homepage.dart'; // 홈 페이지

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Page"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 4, // Adjust elevation to add shadow
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: const Row(
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
                        "홍길동 님",
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
              title: Text("알약 검색 기록"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to 알약 검색 기록 screen
              },
            ),
            ListTile(
              title: Text("즐겨찾는 알약"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 즐겨찾는 알약 화면으로 이동 (Bookmark.dart 실행)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookmarkScreen()),
                );
              },
            ),
            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),
            ListTile(
              title: Text("개인정보 수정"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to 개인정보 수정 screen
              },
            ),
            ListTile(
              title: Text("비밀번호 변경"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordChangeScreen()),
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
                  MaterialPageRoute(builder: (context) => FamilyRegister()), // Added Family Registration navigation
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
                  MaterialPageRoute(builder: (context) => MembershipWithdrawScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
