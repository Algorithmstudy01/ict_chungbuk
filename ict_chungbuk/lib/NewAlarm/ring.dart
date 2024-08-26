import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';

import 'NewAlarm.dart';

class ExampleAlarmRingScreen extends StatelessWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, super.key});

  final AlarmSettings alarmSettings;
  
  Future<void> stopAlarm(AlarmSettings alarmSettings) async {

    DateTime newdDateTime = alarmSettings.dateTime.add(const Duration(days: 7)); 
    final newalarmSettings = AlarmSettings( 
      id: alarmSettings.id,
      dateTime: newdDateTime, 
      loopAudio: alarmSettings.loopAudio, 
      vibrate: alarmSettings.vibrate, 
      volume: alarmSettings.volume, 
      assetAudioPath: alarmSettings.assetAudioPath, 
      notificationTitle: alarmSettings.notificationTitle, 
      notificationBody: alarmSettings.notificationBody, 
      enableNotificationOnKill: alarmSettings.enableNotificationOnKill, 
      sun: alarmSettings.sun,
      mon: alarmSettings.mon,
      tue: alarmSettings.tue,
      wed: alarmSettings.wed,
      thu: alarmSettings.thu,
      fri: alarmSettings.fri,
      sat: alarmSettings.sat,
    );

    Alarm.stop(alarmSettings.id).then((bool result) { 
      return Alarm.set(alarmSettings: newalarmSettings);
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'You alarm (${alarmSettings.id}) is ringing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text('🔔', style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                        ).add(const Duration(minutes: 1)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Snooze',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    stopAlarm(alarmSettings).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Stop',
                    style: Theme.of(context).textTheme.titleLarge,
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
