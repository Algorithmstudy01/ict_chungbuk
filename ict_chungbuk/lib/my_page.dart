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
              title: Text("이메일 변경"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to 이메일 변경 screen
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // Set to white
        selectedItemColor: Colors.black, // Set the selected icon color
        unselectedItemColor: Colors.grey, // Set the unselected icon color
        currentIndex: 3, // Highlight the "MY" tab
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // homepage.dart로 이동
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlarmPage()), // alarm.dart로 이동
            );
          } else if (index == 3) {
            // My Page는 현재 페이지이므로 아무 작업도 하지 않음
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '알림 설정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}
