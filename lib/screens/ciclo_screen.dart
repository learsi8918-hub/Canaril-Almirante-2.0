import 'package:flutter/material.dart';
import '../models/ciclo_model.dart';
import '../database/db_helper.dart';

class CicloScreen extends StatefulWidget {
  const CicloScreen({Key? key}) : super(key: key);

  @override
  State<CicloScreen> createState() => _CicloScreenState();
}

class _CicloScreenState extends State<CicloScreen> {
  List<CicloReproducao> _ciclosReais = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarCiclosDoBanco();
  }

  Future<void> _buscarCiclosDoBanco() async {
    final dados = await DBHelper.instance.buscarCiclosAtivos();
    setState(() {
      _ciclosReais = dados;
      _carregando = false;
    });
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final diasHoje = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('🥚 Controle de Reprodução e Choco'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _ciclosReais.isEmpty
              ? const Center(child: Text("Nenhuma gaiola em choco registrada no momento.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _ciclosReais.length,
                  itemBuilder: (context, index) {
                    final ciclo = _ciclosReais[index];
                    final diasDeChoco = diasHoje.difference(ciclo.dataInicioChoco).inDays;

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
                            Text('🧬 Reprodutor: ${ciclo.idMacho} | Matriz: ${ciclo.idFemea}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('📌 Sistema de Acasalamento: ${ciclo.sistemaAcasalamento}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🥚 Ovos Postos: ${ciclo.quantidadeOvos}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
