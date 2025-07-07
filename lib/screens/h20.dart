import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class H20Screen extends StatefulWidget {
  @override
  _H20ScreenState createState() => _H20ScreenState();
}

class _H20ScreenState extends State<H20Screen> {
  int dailyWaterGoal = 2000; // Mục tiêu nước (ml)
  int additionalWater = 250; // Mỗi lần uống nước (ml)
  int consumedWater = 0; // Đã uống (ml)
  bool isReminderOn = false; // Trạng thái nhắc nhở

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    loadPreferences();
    initNotifications(); // Khởi tạo thông báo
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isReminderOn = prefs.getBool("isReminderOn") ?? false;
      consumedWater = prefs.getInt("consumedWater") ?? 0;
    });

    if (isReminderOn) {
      scheduleWaterReminders(); // Hẹn thông báo nếu đã bật
    }
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isReminderOn", isReminderOn);
    prefs.setInt("consumedWater", consumedWater);
  }

  void initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void addWater() {
    setState(() {
      consumedWater += additionalWater;
      if (consumedWater > dailyWaterGoal) consumedWater = dailyWaterGoal;
    });
    savePreferences();

    // Hiện thông báo khi đạt mục tiêu
    if (consumedWater >= dailyWaterGoal) {
      showWaterReminderNotification("Bạn đã đạt mục tiêu!", "Chúc mừng! Bạn đã uống đủ nước hôm nay.");
    }
  }

  void removeWater() {
    setState(() {
      consumedWater -= additionalWater;
      if (consumedWater < 0) consumedWater = 0;
    });
    savePreferences();
  }

  void toggleReminder(bool value) {
    setState(() {
      isReminderOn = value;
    });

    if (isReminderOn) {
      scheduleWaterReminders();
    } else {
      cancelWaterReminders();
    }

    savePreferences();
  }

  Future<void> showWaterReminderNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'water_reminder_id',
      'Lịch uống nước',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
    );
  }

  void scheduleWaterReminders() async {
    for (int i = 1; i <= 8; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'Nhắc nhở uống nước',
        'Hãy uống nước để duy trì sức khỏe!',
        tz.TZDateTime.now(tz.local).add(Duration(hours: i)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder_id',
            'Lịch uống nước',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    print("✅ Đã đặt lịch nhắc nhở uống nước!");
  }

  void cancelWaterReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch uống nước"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lượng nước cần uống trong ngày",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("$dailyWaterGoal ml", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            Text(
              "Lượng nước đã uống",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("$consumedWater ml",
                style: TextStyle(fontSize: 18, color: Colors.blue)),
            SizedBox(height: 10),

            LinearProgressIndicator(
              value: consumedWater / dailyWaterGoal,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: removeWater,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Icon(Icons.remove, size: 30),
                ),
                ElevatedButton(
                  onPressed: addWater,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Icon(Icons.add, size: 30),
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Text(
                  "Thông báo lịch uống nước",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Switch(
                  value: isReminderOn,
                  onChanged: toggleReminder,
                  activeColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 20),

            if (consumedWater >= dailyWaterGoal)
              Center(
                child: Text(
                  "Chúc mừng! Bạn đã đạt mục tiêu uống nước hôm nay!",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}