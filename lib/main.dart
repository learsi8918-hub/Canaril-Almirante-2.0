import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importando a nova barreira de login de segurança

void main() {
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
        primaryColor: const Color(0xFFFFD700), // Amarelo Canário Canônico
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          elevation: 2,
        ),
      ),
      home: const LoginScreen(), // Inicialização agora trancada por autenticação
    );
  }
}
