import 'dart:convert';
import 'package:chungbuk_ict/BookMark.dart';
import 'package:chungbuk_ict/Change_Password.dart';
import 'package:chungbuk_ict/Family_Registration.dart';
import 'package:chungbuk_ict/Membership_Withdrawal.dart';
import 'package:chungbuk_ict/find_pill.dart';
import 'package:chungbuk_ict/pill_information.dart';
import 'package:flutter/material.dart';
import 'my_page.dart';
import 'alarm.dart';
import 'package:http/http.dart' as http;

class TabbarFrame extends StatelessWidget {
  final String userId;
  const TabbarFrame({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 4,
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
                icon: Icon(Icons.search),
                text: "검색",
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
              FindPill(userId: userId),
              AlarmPage(userId: userId), // 알람 페이지
              MyPage(userId: userId), // 내 정보 페이지
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
  List<Map<String, dynamic>> _alarms = []; // 알람 목록

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _fetchAlarms();
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
      setState(() {
        _nickname = 'Unknown User';
      });
    }
  }

  Future<void> _fetchAlarms() async {
    final url = 'http://10.0.2.2:8000/alarms/${widget.userId}/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _alarms = responseData.map((item) {
            return {
              'id': item['id'].toString(),
              'time': item['time'].toString(),
              'days': List<String>.from(item['days']),
              'name': item['name'] ?? '',
              'usage': item['usage'] ?? '',
            };
          }).toList();
        });
      } else {
        print('Failed to load alarms. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(  // 스크롤 가능하게 하기 위해 추가
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // 시작 정렬로 변경
            children: [
              SizedBox(height: 90),  // 상단에 20 픽셀의 여백 추가
              Column(
                children: [
                  Container(
                    width: size.width * 0.23,
                    height: size.width * 0.23,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/img/user5.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.3,
                    height: size.height * 0.05,
                    child: Text(
                      _nickname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontFamily: 'Inter',
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () => DefaultTabController.of(context)!.animateTo(1),
                            icon: Image.asset('assets/img/find_pill.png'),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BookmarkScreen(userId: widget.userId),
                                  ),
                                ),
                                icon: Image.asset('assets/img/favorites.png'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size.width * 0.9,
                    height: size.height * 0.25,
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
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0), // Adjust the padding here
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView( // Ensure scrolling if content overflows
                            child: Text(
                              '알약 복용 알림\n\n${_alarms.map((alarm) => '${alarm['days']} ${alarm['time']} ${alarm['name']}').join('\n')}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              // Optionally, set maxLines and overflow if needed
                            ),
                          );
                        },
                      ),
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
                                  fontSize: size.width * 0.055, // 도움말의 크기를 크게
                                  fontWeight: FontWeight.bold, // 도움말의 글씨를 굵게
                                ),
                              ),
                              TextSpan(
                                text:
                                '야금야금은 다양한 약을 꾸준히 복용해야 하는 분들에게 쉽고 정확하게 약을 복용할 수 있도록 도와주는 어플리케이션입니다.\n\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.045, // 기본 크기
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 약 검색\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, // 항목 제목을 굵게
                                  fontSize: size.width * 0.055, // 제목의 크기를 약간 더 크게
                                ),
                              ),
                              TextSpan(
                                text:
                                '알약 사진을 촬영하면 야금야금이 해당 약물의 이름과 복용 방법을 알려줍니다. 알약 정보에서 음성 아이콘을 누르고 알약의 상세정보를 음성으로 들어보세요!\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.045, // 기본 설명을 조금 작게
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 즐겨찾기\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.055,
                                ),
                              ),
                              TextSpan(
                                text:
                                '사용자가 즐겨 찾는 알약을 즐겨찾기에 추가할 수 있습니다. 나만의 알약 목록을 만들어 편하게 사용해보세요!\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.045,
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 알람\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.055,
                                ),
                              ),
                              TextSpan(
                                text:
                                '알약을 먹어야 할 시간을 등록하면 복용 시간마다 알림이 울립니다.\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.045,
                                ),
                              ),
                              TextSpan(
                                text: '⁃ 내 정보\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.055,
                                ),
                              ),
                              TextSpan(
                                text:
                                '• 지금까지 검색한 알약 기록을 확인할 수 있습니다. \n• 비밀번호를 변경할 수 있습니다. \n• 가족을 등록하고 가족에게 알약을 추천해줄 수 있습니다.\n\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.045,
                                ),
                              ),
                              TextSpan(
                                text: '⚠️주의사항\n\n',
                                style: TextStyle(
                                  fontSize: size.width * 0.055, // 도움말의 크기를 크게
                                  fontWeight: FontWeight.bold, // 도움말의 글씨를 굵게
                                ),
                              ),
                              TextSpan(
                                text:
                                '⁃ 이 어플은 참고용이며, 실제 복약 지침은 의료 전문가의 조언을 우선시하세요.\n\n⁃ 기기 설정에 따라 알림이 울리지 않을 수 있으니 중요한 약물 복용 시 소리 모드를 적용해주세요.',
                                style: TextStyle(
                                  fontSize: size.width * 0.045, // 기본 크기
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
