import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'my_page.dart';

class AlarmPage extends StatefulWidget {
  final String userId;

  AlarmPage({required this.userId});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> alarms = [];

@override
void initState() {
  super.initState();
  _fetchAlarms(); // 페이지 로드 시 알람 목록 가져오기
}

  @override
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TabbarFrame(userId: widget.userId)),
        );
      }
    }
  }
Future<void> _fetchAlarms() async {
  final url = 'http://10.0.2.2:8000/alarms/${widget.userId}/'; // Ensure correct port
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        alarms = responseData.map((item) {
          // Ensure days field is converted to List<String>
          return {
            'id': item['id'],
            'user_id': item['user_id'],
            'time': item['time'],
            'days': List<String>.from(item['days']),
          };
        }).toList();
      });
      print('Fetched alarms: $alarms'); // 디버깅을 위한 출력
    } else {
      print('Failed to load alarms. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching alarms: $e');
  }
}




Future<void> _updateAlarm(int index, String time, List<String> days) async {
  final alarm = alarms[index];
  final alarmId = alarm['id'];

  // alarmId가 null인지 확인
  if (alarmId == null) {
    print('Error: alarmId is null');
    return;
  }

  final url = 'http://10.0.2.2:8000/alarms/update/$alarmId/';
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'time': time,
        'days': days,
      }),
    );
    if (response.statusCode == 200) {
      _fetchAlarms(); // 성공 시 알람 목록 새로고침
    } else {
      print('Failed to update alarm. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating alarm: $e');
  }
}




Future<void> _addNewAlarm() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlarmSettingModal(
        onSave: (time, days) async {
          final url = 'http://10.0.2.2:8000/alarms/create/'; // Django URL
          try {
            final response = await http.post(
              Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, dynamic>{
                'user_id': widget.userId,
                'time': time,
                'days': days,
              }),
            );
            if (response.statusCode == 201) {
              _fetchAlarms();
            } else {
              print('Failed to create alarm. Status code: ${response.statusCode}');
            }
          } catch (e) {
            print('Error creating alarm: $e');
          }
        },
      );
    },
  );
}







  void _showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.grey[900], // Background color for the menu
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('편집', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _editAlarm(context, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }



void _editAlarm(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlarmSettingModal(
        onSave: (time, days) {
          _updateAlarm(index, time, days);
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black),
        ),
          centerTitle: true,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () => _showOptionsMenu(context, index),
              child: AlarmCard(
                activeDays: alarm['days'],
                time: alarm['time'], id: '',
              ),
            ),
          );
        },
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _addNewAlarm,
              backgroundColor: Colors.purple[200],
              child: Icon(Icons.add),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 70),
              child: FloatingActionButton(
                onPressed: () {
                  // Placeholder for future options if needed
                },
                backgroundColor: Colors.purple[200],
                child: Icon(Icons.more_vert),
              ),
            ),
          ),
        ],
      ),
     
    );
  }
}


class AlarmSettingModal extends StatefulWidget {
  final Function(String, List<String>) onSave;

  AlarmSettingModal({required this.onSave});

  @override
  _AlarmSettingModalState createState() => _AlarmSettingModalState();
}

class _AlarmSettingModalState extends State<AlarmSettingModal> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 6, minute: 0);
  List<String> _selectedDays = ['월', '화', '수', '목', '금'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Center(
        child: Text(
          '알람 설정',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null && picked != _selectedTime) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
            child: Text(
              '${_selectedTime.format(context)}',
              style: TextStyle(fontSize: 48, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              bool isSelected = _selectedDays.contains(day);
              return ChoiceChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              '${_selectedTime.format(context)}',
              _selectedDays,
            );
            Navigator.pop(context);
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}class AlarmCard extends StatelessWidget {
  final List<String> activeDays;
  final String time;
  final String id; // id 필드 추가

  AlarmCard({required this.activeDays, required this.time, required this.id}); // id 매개변수 추가

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  for (var day in ['월', '화', '수', '목', '금', '토', '일'])
                    DayWithDot(
                      day: day,
                      isActive: activeDays.contains(day),
                    ),
                ],
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/img/pill.png',
                width: 50,
                height: 50,
              ),
              SizedBox(height: 8),
              Text(
                '약이름',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                '용법',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class DayWithDot extends StatelessWidget {
  final String day;
  final bool isActive;

  DayWithDot({required this.day, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          if (isActive)
            Icon(
              Icons.circle,
              size: 6, // Smaller dot size
              color: Colors.purple,
            ),
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}