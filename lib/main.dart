import 'package:flutter/material.dart';
import 'screens/baixa_screen.dart'; // Importando a nova tela de baixas

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
      home: const BaixaScreen(), // Iniciando na tela de baixas
    );
  }
}
