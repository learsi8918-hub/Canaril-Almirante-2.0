import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
Future<void> main() async {WidgetsFlutterBinding.ensureInitialized();await NotificationService.instance.init();runApp(const CanaryApp());}
class CanaryApp extends StatelessWidget{const CanaryApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Canary Control Pro',theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.green),home:const LoginScreen());}
