import 'dart:convert';
import 'package:chungbuk_ict/BookMark.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
                          icon: Image.asset('assets/img/find_pill2.png'),
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
                              icon: Image.asset('assets/img/img.png'),
                            ),
                            const Text(
                              '즐겨찾기',
                              style: TextStyle(
                                color: Colors.black,
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

              ],
            ),
          ],
        ),
      ),
    );
  }
}
