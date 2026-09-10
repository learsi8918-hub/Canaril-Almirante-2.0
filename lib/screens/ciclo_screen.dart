import 'package:flutter/material.dart';
import '../models/ciclo_model.dart';
import '../database/db_helper.dart';

class CicloScreen extends StatefulWidget {
  const CicloScreen({Key? key}) : super(key: key);

  @override
  State<CicloScreen> createState() => _CicloScreenState();
}

class _CicloScreenState extends State<CicloScreen> {
  final _formKeyCiclo = GlobalKey<FormState>();
  final _gaiolaController = TextEditingController();
  final _machoController = TextEditingController();
  final _femeaController = TextEditingController();
  final _ovosController = TextEditingController();
  final _ferteisController = TextEditingController();
  
  String _sistemaAcasalamento = 'Monogamia';
  String _manejoMacho = 'Sempre Junto';

  List<CicloReproducao> _ciclosAtivos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCiclos();
  }

  Future<void> _carregarCiclos() async {
    final dados = await DBHelper.instance.buscarCiclosAtivos();
    setState(() {
      _ciclosAtivos = dados;
      _carregando = false;
    });
  }

  void _registrarNovoCiclo() async {
    if (_formKeyCiclo.currentState!.validate()) {
      final novoCiclo = CicloReproducao(
        idGaiola: _gaiolaController.text,
        sistemaAcasalamento: _sistemaAcasalamento,
        idMacho: _machoController.text.toUpperCase(),
        idFemea: _femeaController.text.toUpperCase(),
        dataInicioChoco: DateTime.now(),
        quantidadeOvos: int.parse(_ovosController.text),
        ovosFerteis: int.parse(_ferteisController.text),
        tipoManejoMacho: _manejoMacho,
      );

      await DBHelper.instance.salvarCicloReproducao(novoCiclo);
      _gaiolaController.clear();
      _machoController.clear();
      _femeaController.clear();
      _ovosController.clear();
      _ferteisController.clear();
      _carregarCiclos();
      Navigator.pop(context);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _abrirFormularioChoco() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Form(
            key: _formKeyCiclo,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🥚 Iniciar Ciclo de Choco", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _gaiolaController, decoration: const InputDecoration(labelText: 'Nº Gaiola', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a gaiola' : null)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sistemaAcasalamento,
                        decoration: const InputDecoration(labelText: 'Manejo', border: OutlineInputBorder()),
                        items: const [DropdownMenuItem(value: 'Monogamia', child: Text('Monogamia')), DropdownMenuItem(value: 'Bigamia', child: Text('Bigamia')), DropdownMenuItem(value: 'Poligamia', child: Text('Poligamia'))],
                        onChanged: (val) => setModalState(() => _sistemaAcasalamento = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _machoController, decoration: const InputDecoration(labelText: 'Macho', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Macho' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _femeaController, decoration: const InputDecoration(labelText: 'Fêmea', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Fêmea' : null)),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _manejoMacho,
                  decoration: const InputDecoration(labelText: 'Rotina do Macho Reprodutor', border: OutlineInputBorder()),
                  items: const [DropdownMenuItem(value: 'Sempre Junto', child: Text('Macho Fica com a Fêmea')), DropdownMenuItem(value: 'Sai no 3º Ovo', child: Text('Macho Sai após o 3º Ovo')), DropdownMenuItem(value: 'Janela_Copula', child: Text('Macho Sai após Cópula (5h-9h)'))],
                  onChanged: (val) => setModalState(() => _manejoMacho = val!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _ovosController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ovos', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Qtd' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _ferteisController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🔬 Férteis', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Férteis' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), onPressed: _registrarNovoCiclo, child: const Text('Salvar Ciclo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🥚 Controle de Choco'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _ciclosAtivos.isEmpty
              ? const Center(child: Text("Canaril sem chocos ativos.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
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
                            Text('${ciclo.idGaiola} (${ciclo.sistemaAcasalamento})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                            const Divider(),
                            Text('🔬 Ovoscopia: ${_formatarData(ciclo.dataOvoscopia)}'),
                            Text('🐣 Nascimento: ${_formatarData(ciclo.dataNascimento)}', style: const TextStyle(color: Color(0xFFFFD700))),
                            Text('💍 Desmame: ${_formatarData(ciclo.dataNascimento.add(const Duration(days: 22))))}', style: const TextStyle(color: Colors.greenAccent)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFFD700), onPressed: _abrirFormularioChoco, child: const Icon(Icons.add, color: Colors.black)),
    );
  }
}
