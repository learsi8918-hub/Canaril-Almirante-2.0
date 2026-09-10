import 'package:flutter/material.dart';
import '../models/saude_model.dart';
import '../database/db_helper.dart';

class SaudeScreen extends StatefulWidget {
  const SaudeScreen({Key? key}) : super(key: key);

  @override
  State<SaudeScreen> createState() => _SaudeScreenState();
}

class _SaudeScreenState extends State<SaudeScreen> {
  List<OcorrenciaSaude> _historicoReal = [];
  bool _carregando = true;

  final _formKey = GlobalKey<FormState>();
  final _anilhaController = TextEditingController();
  final _clubeController = TextEditingController();
  final _doencaController = TextEditingController();
  final _tratamentoController = TextEditingController();
  String _statusSelecionado = 'Em Tratamento';

  @override
  void initState() {
    super.initState();
    _buscarHistoricoSanitario();
  }

  Future<void> _buscarHistoricoSanitario() async {
    final dados = await DBHelper.instance.buscarHistoricoSaude();
    setState(() {
      _historicoReal = dados;
      _carregando = false;
    });
  }

  void _registrarOcorrencia() async {
    if (_formKey.currentState!.validate()) {
      final identificadorOficial = '${_clubeController.text.toUpperCase()}-${_anilhaController.text}';
      
      final novaOcorrencia = OcorrenciaSaude(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        identificadorAve: identificadorOficial,
        dataDiagnostico: DateTime.now(),
        doencaOuSintoma: _doencaController.text,
        tratamentoAplicado: _tratamentoController.text,
        statusTratamento: _statusSelecionado,
      );

      await DBHelper.instance.salvarOcorrenciaSaude(novaOcorrencia);
      _doencaController.clear();
      _tratamentoController.clear();
      _anilhaController.clear();
      _clubeController.clear();
      
      _buscarHistoricoSanitario();
      Navigator.pop(context);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Curado') return Colors.green;
    if (status == 'Em Tratamento') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Controle de Saúde e Doenças'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📋 Prontuários e Histórico Clínico", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _historicoReal.isEmpty
                        ? const Center(child: Text("Nenhum registro sanitário cadastrado no canaril.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _historicoReal.length,
                            itemBuilder: (context, index) {
                              final ocorrencia = _historicoReal[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Canário: ${ocorrencia.identificadorAve}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFD700))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(ocorrencia.statusTratamento).withOpacity(0.2),
                                              border: Border.all(color: _getStatusColor(ocorrencia.statusTratamento)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(ocorrencia.statusTratamento, style: TextStyle(color: _getStatusColor(ocorrencia.statusTratamento), fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ],
                                        ),
                                      const Divider(height: 16),
                                      Text('🩺 Diagnóstico: ${ocorrencia.doencaOuSintoma}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text('💊 Conduta/Tratamento: ${ocorrencia.tratamentoAplicado}', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                                      const SizedBox(height: 6),
                                      Text('📅 Data: ${ocorrencia.dataDiagnostico.day}/${ocorrencia.dataDiagnostico.month}/${ocorrencia.dataDiagnostico.year}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(Icons.add_alert, color: Colors.black),
        onPressed: () => _abrirFormularioCadastro(context),
      ),
    );
  }

  void _abrirFormularioCadastro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🏥 Registrar Ocorrência Médica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _anilhaController, decoration: const InputDecoration(labelText: 'Nº Anilha', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _clubeController, decoration: const InputDecoration(labelText: 'Sigla Clube', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _doencaController, decoration: const InputDecoration(labelText: 'Doença ou Sintomas Observados', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o diagnóstico' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _tratamentoController, maxLines: 2, decoration: const InputDecoration(labelText: 'Medicamento / Dosagem / Conduta', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o tratamento' : null),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status do Tratamento', border: OutlineInputBorder()),
                  value: _statusSelecionado,
                  items: const [
                    DropdownMenuItem(value: 'Em Tratamento', child: Text('Em Tratamento')),
                    DropdownMenuItem(value: 'Curado', child: Text('Curado')),
                    DropdownMenuItem(value: 'Morta (Sequela)', child: Text('Morta (Sequela)')),
                  ],
                  onChanged: (val) => setState(() => _statusSelecionado = val!),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                    onPressed: _registrarOcorrencia,
                    child: const Text('Salvar na Ficha Médica', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
