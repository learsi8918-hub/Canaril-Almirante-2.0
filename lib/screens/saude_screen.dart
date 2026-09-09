import 'package:flutter/material.dart';
import '../models/saude_model.dart';

class SaudeScreen extends StatefulWidget {
  const SaudeScreen({Key? key}) : super(key: key);

  @override
  State<SaudeScreen> createState() => _SaudeScreenState();
}

class _SaudeScreenState extends State<SaudeScreen> {
  final List<OcorrenciaSaude> _historicoClinico = [
    OcorrenciaSaude(
      id: '1',
      identificadorAve: 'SO-012',
      dataDiagnostico: DateTime.now().subtract(const Duration(days: 15)),
      doencaOuSintoma: 'Peito Seco (Coccidiose)',
      tratamentoAplicado: 'Isolamento em gaiola hospital + Sulfa por 5 dias + Vitaminas',
      statusTratamento: 'Curado',
    ),
    OcorrenciaSaude(
      id: '2',
      identificadorAve: 'FOB-014',
      dataDiagnostico: DateTime.now().subtract(const Duration(days: 2)),
      doencaOuSintoma: 'Ácaro de Traqueia (Rouquidão/Pio Baixo)',
      tratamentoAplicado: 'Aplicação de Ivermectina 1% na nuca (repetir em 15 dias)',
      statusTratamento: 'Em Tratamento',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  String _aveSelecionada = 'SO-012';
  final _doencaController = TextEditingController();
  final _tratamentoController = TextEditingController();
  String _statusSelecionado = 'Em Tratamento';

  void _registrarOcorrencia() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _historicoClinico.add(
          OcorrenciaSaude(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            identificadorAve: _aveSelecionada,
            dataDiagnostico: DateTime.now(),
            doencaOuSintoma: _doencaController.text,
            tratamentoAplicado: _tratamentoController.text,
            statusTratamento: _statusSelecionado,
          ),
        );
        _doencaController.clear();
        _tratamentoController.clear();
      });
      Navigator.pop(context);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Curado': return Colors.green;
      case 'Em Tratamento': return Colors.orange;
      case 'Morta (Sequela)': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Controle de Saúde e Doenças'), backgroundColor: const Color(0xFF1E1E1E)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📋 Prontuários e Histórico Clínico", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Expanded(
              child: _historicoClinico.isEmpty
                  ? const Center(child: Text("Nenhum registro de doença no canaril."))
                  : ListView.builder(
                      itemCount: _historicoClinico.length,
                      itemBuilder: (context, index) {
                        final ocorrencia = _historicoClinico[index];
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Identificador do Canário (Anilha)', border: OutlineInputBorder()),
                  value: _aveSelecionada,
                  items: const [
                    DropdownMenuItem(value: 'SO-012', child: Text('SO-012 (Arlequim)')),
                    DropdownMenuItem(value: 'FOB-014', child: Text('FOB-014 (Vermelho Mosaico)')),
                  ],
                  onChanged: (val) => setState(() => _aveSelecionada = val!),
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
