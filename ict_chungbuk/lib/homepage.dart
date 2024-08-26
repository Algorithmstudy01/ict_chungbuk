import 'package:chungbuk_ict/NewAlarm/NewAlarm.dart';
import 'package:flutter/material.dart';
import 'find_pill.dart';
import 'my_page.dart';
import 'alarm.dart';



class TabbarFrame extends StatelessWidget {
  const TabbarFrame({super.key });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.white,
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
              const MyHomePage(),
              const FindPill(),
              const ExampleAlarmHomeScreen(),
              MyPage()
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  void toDo(){

  }

  @override
  Widget build(BuildContext context){
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: size.width*0.3,
                  height: size.width*0.3,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(43),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width*0.3,
                  height: size.height*0.05,
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
                )
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: size.width*0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: IconButton(onPressed: () => DefaultTabController.of(context).animateTo(1), icon: Image.asset('assets/img/find_pill.png'))
                      ),
                      Expanded(
                          child: IconButton(onPressed: toDo, icon: Image.asset('assets/img/img.png'))
                      ),
                    ],
                  ),
                ),

                Container(
                  width: size.width*0.9,
                  height: size.height*0.2,
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 2) { // Index 2 corresponds to the "알림 설정" tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlarmPage()),
        );
      } else if (index == 3) { // Index 3 corresponds to the "MY" tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Text(
            '사용자 이름',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
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
