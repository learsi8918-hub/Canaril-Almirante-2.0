import 'package:flutter/material.dart';
import '../core/theme_controller.dart';
import 'dashboard_screen.dart';
import 'plantel_screen.dart';
import 'reproduction_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
class NavigationScreen extends StatefulWidget{final AppThemeController theme;const NavigationScreen({super.key,required this.theme});@override State<NavigationScreen> createState()=>_NavigationScreenState();}
class _NavigationScreenState extends State<NavigationScreen>{int i=0;late final pages=[DashboardScreen(theme:widget.theme),PlantelScreen(theme:widget.theme),ReproductionScreen(theme:widget.theme),ReportsScreen(theme:widget.theme),SettingsScreen(theme:widget.theme)];@override Widget build(BuildContext c)=>Scaffold(body:pages[i],bottomNavigationBar:NavigationBar(selectedIndex:i,onDestinationSelected:(v)=>setState(()=>i=v),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Início'),NavigationDestination(icon:Icon(Icons.flutter_dash),label:'Plantel'),NavigationDestination(icon:Icon(Icons.favorite_border),selectedIcon:Icon(Icons.favorite),label:'Reprodução'),NavigationDestination(icon:Icon(Icons.bar_chart),label:'Relatórios'),NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Config.') ]));}
