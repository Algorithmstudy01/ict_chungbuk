
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'find_pill.dart';

late List<CameraDescription> _cameras;

void main() async {
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          bottomNavigationBar: TabBar(
            indicatorColor: Colors.white,
            labelStyle: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 11),
            indicatorWeight: 4,
            tabs: [
              Tab(
                icon: Image.asset('assets/img/home.png',width: 30, height: 30),
                text: "홈",
              ),
              Tab(
                icon: Image.asset('assets/img/magnify.png', color: const Color(0xFF333333),width: 30, height: 30,),
                text: "검색",
              ),
              Tab(
                icon: Image.asset('assets/img/clock.png',width: 30, height: 30),
                text: "알람",
              ),
              Tab(
                icon: Image.asset('assets/img/profile.png',width: 30, height: 30),
                text: "내정보",
              )
            ],
            ),
          body: TabBarView(
            children: [
              const MyHomePage(title: 'Flutter Demo Home Page'),
              FindPill(title: 'Find pill informations', cameras: _cameras),
              Container(),
              Container()
            ],
          ),
          ),
        ),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
