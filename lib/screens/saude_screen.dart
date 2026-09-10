import 'package:flutter/material.dart';
import '../models/saude_model.dart';
import '../database/db_helper.dart';

class SaudeScreen extends StatefulWidget {
  const SaudeScreen({Key? key}) : super(key: key);

  @override
  State<SaudeScreen> createState() => _SaudeScreenState();
}

class _SaudeScreenState extends State<SaudeScreen> {
  List<OcorrenciaSaude> _historicoClinicoReal = [];
  bool _carregando = true;

  final _formKeySaude = GlobalKey<FormState>();
  final _anilhaController = TextEditingController();
  final _clubeController = TextEditingController();
  final _doencaController = TextEditingController();
  final _tratamentoController = TextEditingController();
  final _duracaoController = TextEditingController(text: '5'); // Ciclo padrão solicitado: 5 dias
  String _statusTratamentoSelecionado = 'Em Tratamento';

  @override
  void initState() {
    super.initState();
    _carregarHistoricoSanitario();
  }

  Future<void> _carregarHistoricoSanitario() async {
    setState(() => _carregando = true);
    final dados = await DBHelper.instance.buscarHistoricoSaude();
    setState(() {
      _historicoClinicoReal = dados;
      _carregando = false;
    });
  }

  void _gravarOcorrenciaMedica() async {
    if (_formKeySaude.currentState!.validate()) {
      final identificadorOficial = '${_clubeController.text.toUpperCase()}-${_anilhaController.text}';
      
      final novaOcorrencia = OcorrenciaSaude(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        identificadorAve: identificadorOficial,
        dataDiagnostico: DateTime.now(),
        doencaOuSintoma: _doencaController.text,
        tratamentoAplicado: _tratamentoController.text,
        statusTratamento: _statusTratamentoSelecionado,
      );

      await DBHelper.instance.salvarOcorrenciaSaude(novaOcorrencia);
      
      _anilhaController.clear();
      _clubeController.clear();
      _doencaController.clear();
      _tratamentoController.clear();
      _duracaoController.text = '5';

      _carregarHistoricoSanitario();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏥 Ficha clínica salva e ciclo de quarentena ativo!'), backgroundColor: Colors.green),
      );
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
      appBar: AppBar(
        title: const Text('🏥 Prontuário Médico & Quarentena'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📋 Histórico Sanitário do Plantel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _historicoClinicoReal.isEmpty
                        ? const Center(child: Text("Nenhuma ave em quarentena ou tratamento clínico.", style: TextStyle(color: Colors.grey, fontSize: 13)))
                        : ListView.builder(
                            itemCount: _historicoClinicoReal.length,
                            itemBuilder: (context, index) {
                              final ocorrencia = _historicoClinicoReal[index];
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
                                          Text('Ave: ${ocorrencia.identificadorAve}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFFFD700))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(ocorrencia.statusTratamento).withOpacity(0.1),
                                              border: Border.all(color: _getStatusColor(ocorrencia.statusTratamento)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(ocorrencia.statusTratamento, style: TextStyle(color: _getStatusColor(ocorrencia.statusTratamento), fontWeight: FontWeight.bold, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Text('🩺 Diagnóstico: ${ocorrencia.doencaOuSintoma}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text('💊 Protocolo: ${ocorrencia.tratamentoAplicado}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('📅 Início: ${ocorrencia.dataDiagnostico.day}/${ocorrencia.dataDiagnostico.month}/${ocorrencia.dataDiagnostico.year}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                          const Text('⏱️ Ciclo: 5 dias (Água)', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
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
        onPressed: () => _abrirFormularioSanitario(context),
      ),
    );
  }

  void _abrirFormularioSanitario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: Form(
              key: _formKeySaude,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🏥 Lançar Ocorrência Clínica / Quarentena", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _anilhaController, decoration: const InputDecoration(labelText: 'Nº Anilha', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a anilha' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _clubeController, maxLength: 2, decoration: const InputDecoration(labelText: 'Clube (2 Letras)', border: OutlineInputBorder(), counterText: ""), validator: (val) => val!.length != 2 ? 'Use 2 letras' : null)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _doencaController, decoration: const InputDecoration(labelText: 'Doença / Sintomas (Ex: Peito Seco, Ácaro)', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o diagnóstico' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _tratamentoController, maxLines: 2, decoration: const InputDecoration(labelText: 'Medicamento / Dosagem na Água', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a conduta' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _duracaoController, enabled: false, decoration: const InputDecoration(labelText: 'Duração Padrão do Ciclo (Dias)', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _statusTratamentoSelecionado,
                    decoration: const InputDecoration(labelText: 'Status Clínico Inicial', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Em Tratamento', child: Text('Em Tratamento (Quarentena)')),
                      DropdownMenuItem(value: 'Curado', child: Text('Curado (Retorna ao Plantel)')),
                      DropdownMenuItem(value: 'Óbito', child: Text('Óbito (Morte)')),
                    ],
                    onChanged: (val) => setModalState(() => _statusTratamentoSelecionado = val!),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                      onPressed: _gravarOcorrenciaMedica,
                      child: const Text('Gravar e Ativar Isolamento', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
