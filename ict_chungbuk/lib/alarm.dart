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
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        alarms = responseData.map((item) {
          return {
            'id': item['id'].toString(),
            'user_id': item['user_id'].toString(),
            'time': item['time'].toString(),
            'days': List<String>.from(item['days']),
            'name': item['name'] ?? '',
            'usage': item['usage'] ?? '',
          };
        }).toList();
      });
      print('Fetched alarms: $alarms'); // For debugging
    } else {
      print('Failed to load alarms. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching alarms: $e');
  }
}



  Future<void> _updateAlarm(int index, String time, List<String> days, String name, String usage) async {
    final alarm = alarms[index];
    final alarmId = alarm['id'];

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
          'name': name,
          'usage': usage,
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

  Future<void> _deleteAlarm(int index) async {
    final alarm = alarms[index];
    final alarmId = alarm['id'];

    if (alarmId == null) {
      print('Error: alarmId is null');
      return;
    }

    final url = 'http://10.0.2.2:8000/alarms/delete/$alarmId/';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        setState(() {
          alarms.removeAt(index); // 성공 시 해당 알람을 목록에서 제거
        });
        print('Alarm deleted successfully');
      } else {
        print('Failed to delete alarm. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting alarm: $e');
    }
  }

  Future<void> _addNewAlarm() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlarmSettingModal(
          onSave: (time, days, name, usage) async {
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
                  'name': name,
                  'usage': usage,
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
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('편집', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _editAlarm(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.white),
                title: Text('삭제', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAlarm(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editAlarm(int index) {
    final alarm = alarms[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlarmSettingModal(
          initialTime: TimeOfDay(
            hour: int.tryParse(alarm['time'].split(':')[0]) ?? 0,
            minute: int.tryParse(alarm['time'].split(':')[1]) ?? 0,
          ),
          initialDays: List<String>.from(alarm['days']),
          initialName: alarm['name'],
          initialUsage: alarm['usage'],
          onSave: (time, days, name, usage) {
            _updateAlarm(index, time, days, name, usage);
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
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return GestureDetector(
            onTap: () => _showOptionsMenu(context, index),
            child: AlarmCard(
              activeDays: List<String>.from(alarm['days']),
              time: alarm['time'],
              id: alarm['id'],
              name: alarm['name'],
              usage: alarm['usage'],
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
  final Function(String time, List<String> days, String name, String usage) onSave;
  final TimeOfDay? initialTime;
  final List<String>? initialDays;
  final String? initialName;
  final String? initialUsage;

  const AlarmSettingModal({
    required this.onSave,
    this.initialTime,
    this.initialDays,
    this.initialName,
    this.initialUsage,
  });

  @override
  _AlarmSettingModalState createState() => _AlarmSettingModalState();
}

class _AlarmSettingModalState extends State<AlarmSettingModal> {
  late TimeOfDay _selectedTime;
  List<String> _selectedDays = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
    _selectedDays = widget.initialDays ?? [];
    _nameController.text = widget.initialName ?? '';
    _usageController.text = widget.initialUsage ?? '';
  }

  void _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('알람 설정', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '시간 선택: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '${_selectedTime.format(context)}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _nameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '이름',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _usageController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '사용 용도',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            children: [
              _buildDayChip('월', '월'),
              _buildDayChip('화', '화'),
              _buildDayChip('수', '수'),
              _buildDayChip('목', '목'),
              _buildDayChip('금', '금'),
              _buildDayChip('토', '토'),
              _buildDayChip('일', '일'),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('취소', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
          child: Text('저장'),
          onPressed: () {
            final formattedTime = _selectedTime.format(context);
            final days = _selectedDays;
            final name = _nameController.text;
            final usage = _usageController.text;
            widget.onSave(formattedTime, days, name, usage);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildDayChip(String label, String day) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Color.fromARGB(255, 149, 142, 142) : Colors.white)),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
      selectedColor: Colors.purple[200],
      backgroundColor: Colors.grey[800],
    );
  }
}

class AlarmCard extends StatelessWidget {
  final List<String> activeDays;
  final String time;
  final String id;
  final String name;
  final String usage;

  const AlarmCard({
    required this.activeDays,
    required this.time,
    required this.id,
    required this.name,
    required this.usage,
  });
@override
Widget build(BuildContext context) {
  return Card(
    color: Colors.grey[400],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50, // 이미지의 너비
            height: 50, // 이미지의 높이
            child: Image.asset(
              'assets/img/pill.png',
            ),
          ),
          SizedBox(width: 16.0), // 이미지와 텍스트 사이의 간격
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 6, 5, 5),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '시간: $time',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '요일: ${activeDays.join(', ')}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '이름: $name',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '사용 용도: $usage',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}