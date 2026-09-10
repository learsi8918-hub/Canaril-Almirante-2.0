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
  
  // Controladores do Formulário de Choco
  final _gaiolaController = TextEditingController();
  final _machoController = TextEditingController();
  final _femeaController = TextEditingController();
  final _ovosController = TextEditingController();
  final _ferteisController = TextEditingController();
  
  String _sistemaAcasalamento = 'Monogamia';
  String _manejoMacho = 'Sempre Junto'; // Opções: Sempre Junto, Sai no 3º Ovo, Janela de Cópula (5h-9h)

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🥚 Ciclo reprodutivo registrado e alarmes offline agendados!'), backgroundColor: Colors.green),
      );
    }
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
                const Text("🥚 Iniciar Ciclo de Choco e Reprodução", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _gaiolaController, decoration: const InputDecoration(labelText: 'Nº Gaiola', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a gaiola' : null)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sistemaAcasalamento,
                        decoration: const InputDecoration(labelText: 'Manejo', border: OutlineInputBorder()),
                        items: const [DropdownMenuItem(value: 'Monogamia', child: Text('Monogamia')), DropdownMenuItem(value: 'Bigamia', child: Text('Bigamia (Mesma Gaiola)')), DropdownMenuItem(value: 'Poligamia', child: Text('Poligamia (Macho Passa)'))],
                        onChanged: (val) => setModalState(() => _sistemaAcasalamento = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _machoController, decoration: const InputDecoration(labelText: 'Macho (Ex: SOGO-35)', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o macho' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _femeaController, decoration: const InputDecoration(labelText: 'Fêmea (Ex: OZ-12)', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a fêmea' : null)),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _manejoMacho,
                  decoration: const InputDecoration(labelText: 'Rotina do Macho Reprodutor', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Sempre Junto', child: Text('Macho Fica com a Fêmea (Sempre Junto)')),
                    DropdownMenuItem(value: 'Sai no 3º Ovo', child: Text('Macho Sai após o 3º Ovo')),
                    DropdownMenuItem(value: 'Janela_Copula', child: Text('Macho Sai após Cópula (5h às 9h)')),
                  ],
                  onChanged: (val) => setModalState(() => _manejoMacho = val!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _ovosController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qtd Ovos Postos', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Qtd' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _ferteisController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🔬 Ovos Férteis', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Férteis' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), onPressed: _registrarNovoCiclo, child: const Text('Salvar e Ativar Cronograma', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
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
                    final ovosNaoFerteis = ciclo.quantidadeOvos - ciclo.ovosFerteis;

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
                                Text('${ciclo.idGaiola} (${ciclo.sistemaAcasalamento})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                                Chip(label: Text('$diasDeChoco° Dia'), backgroundColor: Colors.amber.shade900.withOpacity(0.3)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('🚹 Macho: ${ciclo.idMacho} | 🚺 Fêmea: ${ciclo.idFemea}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('⏱️ Manejo: ${ciclo.tipoManejoMacho == 'Janela_Copula' ? 'Cópula (5h-9h)' : ciclo.tipoManejoMacho}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🥚 Totais: ${ciclo.quantidadeOvos}', style: const TextStyle(fontSize: 13)),
                                Text('🔬 Férteis: ${ciclo.ovosFerteis}', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('⚫ Brancos: $ovosNaoFerteis', style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('📅 Gatilhos Fixos Calculados:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Text('🔬 Ovoscopia: ${_formatarData(ciclo.dataOvoscopia)}', style: const TextStyle(fontSize: 12)),
                            Text('🐣 Nascimento: ${_formatarData(ciclo.dataNascimento)}', style: const TextStyle(fontSize: 12, color: Color(0xFFFFD700))),
                            Text('💍 Desmame (Fêmea em descanso): ${_formatarData(ciclo.dataAnilhamento.add(const Duration(days: 17)))}', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),],),),);},),floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFFD700), onPressed: _abrirFormularioChoco, child: const Icon(Icons.add, color: Colors.black)),);}}
