import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ciclo_screen.dart';
import 'saude_screen.dart';
import 'plantel_cadastro_screen.dart';
import 'retrocruzamento_screen.dart'; // Nova tela integrada

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _indiceAtual = 0;

  final List<Widget> _telas = [
    const DashboardScreen(),
    const CicloScreen(),
    const SaudeScreen(),
    const PlantelCadastroScreen(),
    const RetrocruzamentoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceAtual, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (index) => setState(() => _indiceAtual = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Genética'),
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Choco'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Saúde'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Plantel'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Retorno'),
        ],
      ),
    );
  }
}
