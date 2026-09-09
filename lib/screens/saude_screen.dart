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
    if (status == 'Curado') return Colors.green;
    if (status == 'Em Tratamento') return Colors.orange;
    return Colors.red;
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
                                  
