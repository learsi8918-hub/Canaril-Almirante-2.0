import 'package:flutter/material.dart';
import 'core/theme_controller.dart';
import 'database/db_helper.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
void main() async { WidgetsFlutterBinding.ensureInitialized(); await DBHelper.db; await NotificationService.instance.init(); final theme=AppThemeController(); await theme.load(); runApp(CanaryControlPro(theme:theme)); }
class CanaryControlPro extends StatelessWidget { final AppThemeController theme; const CanaryControlPro({super.key,required this.theme}); @override Widget build(BuildContext context)=>AnimatedBuilder(animation:theme,builder:(_,__)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Canary Control Pro',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:theme.primary,brightness:Brightness.light,surface:theme.surface),scaffoldBackgroundColor:theme.surface,appBarTheme:AppBarTheme(backgroundColor:theme.primary,foregroundColor:theme.onPrimary,elevation:0),cardTheme:const CardThemeData(margin:EdgeInsets.zero,elevation:1),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder(),filled:true)),home:LoginScreen(theme:theme))); }
