import 'package:flutter/material.dart';
import '../models/ciclo_model.dart';

class CicloScreen extends StatefulWidget {
  const CicloScreen({Key? key}) : super(key: key);

  @override
  State<CicloScreen> createState() => _CicloScreenState();
}

class _CicloScreenState extends State<CicloScreen> {
  final List<CicloReproducao> _ciclosAtivos = [
    CicloReproducao(
      idGaiola: 'Gaiola 04',
      idMacho: 'SO-012',
      idFemea: 'SO-008',
      dataInicioChoco: DateTime.now().subtract(const Duration(days: 5)),
      quantidadeOvos: 4,
      tipoManejoMacho: 'Sempre Junto',
    ),
    CicloReproducao(
      idGaiola: 'Gaiola 11',
      idMacho: 'SO-005',
      idFemea: 'FOB-014',
      dataInicioChoco: DateTime.now().subtract(const Duration(days: 12)),
      quantidadeOvos: 5,
      ovosFerteis: 4,
      tipoManejoMacho: 'Separado no 3º Ovo',
    ),
  ];

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥚 Controle de Reprodução e Choco'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _ciclosAtivos.length,
        itemBuilder: (context, index) {
          final ciclo = _ciclosAtivos[index];
          final diasDeChoco = DateTime.now().difference(ciclo.dataInicioChoco).inDays;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ciclo.idGaiola, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                      Chip(label: Text('$diasDeChoco° Dia de Choco'), backgroundColor: Colors.amber.shade900.withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('🧬 Macho: ${ciclo.idMacho} | Fêmea: ${ciclo.idFemea}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('📌 Manejo do Macho: ${ciclo.tipoManejoMacho}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🥚 Ovos Postos: ${ciclo.quantidadeOvos}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (diasDeChoco >= 7)
                        Text('🔬 Galados: ${ciclo.ovosFerteis}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('📅 Cronograma e Gatilhos de Manejo:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildLinhaCronograma(titulo: '🔬 Ovoscopia (7º dia):', data: ciclo.dataOvoscopia, concluido: diasDeChoco >= 7),
                  _buildLinhaCronograma(titulo: '🛁 Colocar Banheira (12º dia):', data: ciclo.dataBanheira, concluido: diasDeChoco >= 12),
                  _buildLinhaCronograma(titulo: '🐣 Previsão de Nascimento (13º dia):', data: ciclo.dataNascimento, concluido: diasDeChoco >= 13, destaque: true),
                  _buildLinhaCronograma(titulo: '💍 Anilhamento dos Filhotes (18º dia):', data: ciclo.dataAnilhamento, concluido: diasDeChoco >= 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinhaCronograma({required String titulo, required DateTime data, required bool concluido, bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: TextStyle(color: destaque ? const Color(0xFFFFD700) : (concluido ? Colors.grey : Colors.white), fontWeight: destaque ? FontWeight.bold : FontWeight.normal)),
          Text(_formatarData(data), style: TextStyle(color: concluido ? Colors.green : (destaque ? const Color(0xFFFFD700) : Colors.white), decoration: concluido ? TextDecoration.lineThrough : null, fontWeight: destaque ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
