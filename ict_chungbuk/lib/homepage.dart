import 'dart:convert';

import 'package:chungbuk_ict/find_pill.dart';
import 'package:flutter/material.dart';
import 'my_page.dart';
import 'alarm.dart';
import 'package:http/http.dart' as http;
import 'pill_information.dart'; // pill_information.dart 파일을 임포트

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
              AlarmPage(userId: userId), // 수정된 부분
              MyPage(userId: userId), // 수정된 부분
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationScreen(
          pillCode: _pillInfo['pill_code'] ?? 'Unknown',
          pillName: _pillInfo['product_name'] ?? 'Unknown',
          confidence: _pillInfo['prediction_score']?.toString() ?? 'Unknown',
          userId: widget.userId,
          usage: _pillInfo['usage'] ?? 'No information',
          precautionsBeforeUse: _pillInfo['precautions_before_use'] ?? 'No information',
          usagePrecautions: _pillInfo['usage_precautions'] ?? 'No information',
          drugFoodInteractions: _pillInfo['drug_food_interactions'] ?? 'No information',
          sideEffects: _pillInfo['side_effects'] ?? 'No information',
          storageInstructions: _pillInfo['storage_instructions'] ?? 'No information',
          efficacy: _pillInfo['efficacy'] ?? 'No information', // 추가된 부분
          manufacturer: _pillInfo['manufacturer'] ?? 'No information', // 추가된 부분
          extractedText: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(43),
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
                              onPressed: openPillInformation, // 알약 기록 버튼 클릭 시 실행
                              icon: Image.asset('assets/img/img.png'),
                            ),
                            const Text(
                              '알약 기록',
                              style: TextStyle(
                                color: Colors.black, // Assuming the image has a dark background
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      ),
                    ],
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
