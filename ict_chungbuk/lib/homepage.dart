import 'dart:convert';
import 'BookMark.dart';
import 'package:chungbuk_ict/find_pill.dart';
import 'package:chungbuk_ict/search_history_screen.dart';
import 'package:flutter/material.dart';
import 'my_page.dart';
import 'package:chungbuk_ict/NewAlarm/NewAlarm.dart';
import 'package:http/http.dart' as http;
import 'pill_information.dart'; // pill_information.dart 파일을 임포트



class TabbarFrame extends StatelessWidget {
  final String userId;
  const TabbarFrame({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 3,  // Updated length to 3 since there are 3 tabs
        child: Scaffold(
          bottomNavigationBar: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 11),
            indicatorWeight: 4,
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: "홈",
              ),
              Tab(
                icon: Icon(Icons.alarm),
                text: "알람",
              ),
              Tab(
                icon: Icon(Icons.person),
                text: "내정보",
              )
            ],
          ),
          body: TabBarView(
            children: [
              MyHomePage(userId: userId),
              const ExampleAlarmHomeScreen(), // AlarmPage is from alarm.dart
              MyPage(userId: userId),
            ],
          ),
        ),

      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _nickname = '';
  Map<String, dynamic> _pillInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchNickname();
  }

  Future<void> _fetchNickname() async {
    final response =
    await http.get(Uri.parse('http://10.0.2.2:8000/user_info/${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nickname = data['nickname'] ?? 'Unknown User';
      });
    } else {
      // Handle error
      setState(() {
        _nickname = 'Unknown User';
      });
    }
  }

  void openPillInformation() {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchHistoryScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: size.width * 0.3,
                    height: size.width * 0.3,
                    margin: EdgeInsets.only(top: size.width * 0.25),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(43),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.width * 0.05),
                    child: SizedBox(
                      width: size.width * 0.3,
                      height: size.height * 0.05,
                      child: const Text(
                        '윤순연님',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: size.width * 0.2),
                    child: SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => FindPill(userId: widget.userId))
                                  ),
                              icon: Image.asset('assets/img/find_pill.png'),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookmarkScreen(userId:widget.userId),
                                      ), // Corrected here
                                    );
                                  },
                                  icon: Image.asset('assets/img/favorites.png'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: size.width * 0.9,
                    height: size.height * 0.2,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE4DDF1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: size.width * 0.9,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: ShapeDecoration(
                      color: const Color(0xffe0d3fb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft, // 왼쪽 위에 정렬
                      child: Padding(
                        padding: const EdgeInsets.all(15.0), // 텍스트와 경계 사이에 여백 추가
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black, // 기본 글씨 색상
                              fontSize: size.width * 0.7, // 기본 글씨 크기
                            ),
                            children: [
                              TextSpan(
                                text: '💡도움말\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.06, // 도움말의 크기를 크게
                                  fontWeight: FontWeight.bold, // 도움말의 글씨를 굵게
                                ),
                              ),
                              TextSpan(
                                text:
                                '야금야금은 다양한 약을 꾸준히 복용해야 하는 분들에게 쉽고 정확하게 약을 복용할 수 있도록 도와주는 어플리케이션입니다.\n\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.05, // 기본 크기
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 약 검색\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, // 항목 제목을 굵게
                                  fontSize: size.width * 0.06, // 제목의 크기를 약간 더 크게
                                ),
                              ),
                              TextSpan(
                                text:
                                '알약 사진을 촬영하면 야금야금이 해당 약물의 이름과 복용 방법을 알려줍니다. 알약 정보에서 음성 아이콘을 누르고 알약의 상세정보를 음성으로 들어보세요!\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.05, // 기본 설명을 조금 작게
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 즐겨찾기\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.06,
                                ),
                              ),
                              TextSpan(
                                text:
                                '사용자가 즐겨 찾는 알약을 즐겨찾기에 추가할 수 있습니다. 나만의 알약 목록을 만들어 편하게 사용해보세요!\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 알람\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.06,
                                ),
                              ),
                              TextSpan(
                                text:
                                '알약을 먹어야 할 시간을 등록하면 복용 시간마다 알림이 울립니다.\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 내 정보\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.06,
                                ),
                              ),
                              TextSpan(
                                text:
                                '• 지금까지 검색한 알약 기록을 확인할 수 있습니다. \n• 비밀번호를 변경할 수 있습니다. \n• 가족을 등록하고 가족에게 알약을 추천해줄 수 있습니다.\n\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                ),
                              ),
                              TextSpan(
                                text: '⚠️주의사항\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.06, // 도움말의 크기를 크게
                                  fontWeight: FontWeight.bold, // 도움말의 글씨를 굵게
                                ),
                              ),
                              TextSpan(
                                text:
                                '⁃ 이 어플은 참고용이며, 실제 복약 지침은 의료 전문가의 조언을 우선시하세요.\n\n⁃ 기기 설정에 따라 알림이 울리지 않을 수 있으니 중요한 약물 복용 시 소리 모드를 적용해주세요.',
                                style: TextStyle(
                                  fontSize: size.width * 0.05, // 기본 크기
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
