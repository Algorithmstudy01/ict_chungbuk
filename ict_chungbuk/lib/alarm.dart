import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the HomePage class
import 'my_page.dart'; // Import the MyPage class

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> alarms = [];

  void _addNewAlarm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlarmSettingModal(
          onSave: (time, days) {
            setState(() {
              alarms.add({
                'time': time,
                'days': days,
              });
            });
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
            setState(() {
              alarms[index] = {
                'time': time,
                'days': days,
              };
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation to create a shadow effect
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
                time: alarm['time'],
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
              child: const Icon(Icons.add),
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
                child: const Icon(Icons.more_vert),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class AlarmSettingModal extends StatefulWidget {
  final Function(String, List<String>) onSave;

  AlarmSettingModal({required this.onSave});

  @override
  _AlarmSettingModalState createState() => _AlarmSettingModalState();
}

class _AlarmSettingModalState extends State<AlarmSettingModal>{
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
}

class AlarmCard extends StatelessWidget {
  final List<String> activeDays;
  final String time;

  AlarmCard({required this.activeDays, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[400], // Grey background color
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
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left of the image
            children: [
              Image.asset(
                'assets/pill_icon.png', // Replace with the path to your image asset
                width: 50,
                height: 50,
              ),
              SizedBox(height: 8),
              Text(
                '약이름',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Set text color to white
                ),
              ),
              Text(
                '용법',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Set text color to white
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
