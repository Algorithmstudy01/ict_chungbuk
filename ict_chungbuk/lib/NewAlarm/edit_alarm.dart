import 'dart:io';

import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;

  static const nbDays =7;
  late bool mon, tue, wed, thu, fri, sat, sun;
  late List<int> days;

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
      mon = false;
      tue = false;
      wed = false;
      thu = false;
      fri = false;
      sat = false;
      sun = false;

    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
      mon = widget.alarmSettings!.mon;
      tue = widget.alarmSettings!.tue;
      wed = widget.alarmSettings!.wed;
      thu = widget.alarmSettings!.thu;
      fri = widget.alarmSettings!.fri;
      sat = widget.alarmSettings!.sat;
      sun = widget.alarmSettings!.sun;
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: 'Alarm example',
      notificationBody: 'Your alarm ($id) is ringing',
      enableNotificationOnKill: Platform.isAndroid,
      mon: mon,
      tue: tue,
      wed: wed,
      thu: thu,
      fri: fri,
      sat: sat,
      sun: sun,
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: saveAlarm,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Save',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.blueAccent),
                      ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Checkbox(value: sun, onChanged: (value) => setState(() => sun = value!)),
                Text('일', style: TextStyle(color: sun ? Colors.red : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: mon, onChanged: (value) => setState(() => mon = value!)),
                Text('월', style: TextStyle(color: mon ? Colors.black : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: tue, onChanged: (value) => setState(() => tue = value!)),
                Text('화', style: TextStyle(color: tue ? Colors.black : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: wed, onChanged: (value) => setState(() => wed = value!)),
                Text('수', style: TextStyle(color: wed ? Colors.black : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: thu, onChanged: (value) => setState(() => thu = value!)),
                Text('목', style: TextStyle(color: thu ? Colors.black : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: fri, onChanged: (value) => setState(() => fri = value!)),
                Text('금', style: TextStyle(color: fri ? Colors.black : Colors.grey),)
              ],),
              Column(children: [
                Checkbox(value: sat, onChanged: (value) => setState(() => sat = value!)),
                Text('토', style: TextStyle(color: sat ? Colors.blueAccent : Colors.grey),)
              ],),


            ],
          ),
          Text(
            getDay(),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                TimeOfDay.fromDateTime(selectedDateTime).format(context),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: assetAudio,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/nokia.mp3',
                    child: Text('Nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/mozart.mp3',
                    child: Text('Mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/star_wars.mp3',
                    child: Text('Star Wars'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/one_piece.mp3',
                    child: Text('One Piece'),
                  ),
                ],
                onChanged: (value) => setState(() => assetAudio = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.5 : null),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        volume! > 0.7
                            ? Icons.volume_up_rounded
                            : volume! > 0.1
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded,
                      ),
                      Expanded(
                        child: Slider(
                          value: volume!,
                          onChanged: (value) {
                            setState(() => volume = value);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                'Delete Alarm',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );
  }
}


