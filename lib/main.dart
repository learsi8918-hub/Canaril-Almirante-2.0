import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Garante a vinculação das chamadas nativas de hardware antes de abrir o app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ativa o motor de alarmes em segundo plano para alertas offline
  await NotificationService.instance.inicializar();

  runApp(const CanaryControlApp());
}

class CanaryControlApp extends StatelessWidget {
  const CanaryControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CanaryControl Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700), // Ouro Canário Canônico
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 2,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
