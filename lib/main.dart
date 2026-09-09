import 'package:flutter/material.dart';
import 'main_ui.dart';

void main() {
  // Chave de ignição que inicializa o aplicativo profissional do Canaril Almirante
  runApp(CanarilAlmiranteApp());
}

class CanarilAlmiranteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canaril Almirante',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1E3A8A), // Azul Náutico oficial
        useMaterial3: true,
      ),
      home: AplicativoHome(), // Abre direto na tela com as abas que desenhamos
    );
  }
}
