import 'package:flutter/material.dart';
import 'screens/ciclo_screen.dart'; // Importando a tela de ciclos

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
        primaryColor: const Color(0xFFFFD700),
      ),
      home: const CicloScreen(), // Iniciando na tela de reprodução e choco
    );
  }
}
