import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._(); static final instance=NotificationService._();
  final plugin=FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    tz.initializeTimeZones();
    const android=AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android: android));
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }
  Future<void> schedule(int id,String title,String body,DateTime date) async {
    if(date.isBefore(DateTime.now())) return;
    await plugin.zonedSchedule(id,title,body,tz.TZDateTime.from(date,tz.local),const NotificationDetails(android: AndroidNotificationDetails('canary_agenda','Agenda do Canaril',channelDescription:'Lembretes de reprodução, saúde e manejo',importance: Importance.high,priority: Priority.high)),androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}
