import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ciclo_screen.dart';
import 'saude_screen.dart';
import 'plantel_cadastro_screen.dart'; // Abre a nova tela de cadastro de matrizes
import 'exportacao_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _indiceAtual = 0;

  // Lista de telas que aparecem ao clicar nos botões de baixo do celular
  final List<Widget> _telas = [
    const DashboardScreen(),
    const CicloScreen(),
    const SaudeScreen(),
    const PlantelCadastroScreen(), // Adicionado o cadastro do plantel aqui
    const ExportacaoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: (index) {
          setState(() {
            _indiceAtual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            activeIcon: Icon(Icons.science),
            label: 'Genética',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg_outlined),
            activeIcon: Icon(Icons.egg),
            label: 'Choco',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            activeIcon: Icon(Icons.health_and_safety),
            label: 'Saúde',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined), // Ícone de caixinha para o Plantel
            activeIcon: Icon(Icons.add_box),
            label: 'Plantel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}
