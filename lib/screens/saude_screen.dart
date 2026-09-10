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
  final _duracaoController = TextEditingController(text: '5');
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
      final novaOcorrencia = OcorrenciaSaude(id: DateTime.now().millisecondsSinceEpoch.toString(), identificadorAve: identificadorOficial, dataDiagnostico: DateTime.now(), doencaOuSintoma: _doencaController.text, tratamentoAplicado: _tratamentoController.text, statusTratamento: _statusTratamentoSelecionado);
      await DBHelper.instance.salvarOcorrenciaSaude(novaOcorrencia);
      _anilhaController.clear();
      _clubeController.clear();
      _doencaController.clear();
      _tratamentoController.clear();
      _carregarHistoricoSanitario();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Prontuário Médico'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _historicoClinicoReal.length,
              itemBuilder: (context, index) {
                final o = _historicoClinicoReal[index];
                return Card(child: ListTile(title: Text(o.identificadorAve), subtitle: Text(o.doencaOuSintoma), trailing: Text(o.statusTratamento)));
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: () => _abrirFormularioSanitario(context),
        child: const Icon(Icons.add_alert, color: Colors.black),
      ),
    );
  }

  void _abrirFormularioSanitario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Form(
            key: _formKeySaude,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Lançar Ocorrência"),
                Row(children: [Expanded(child: TextFormField(controller: _anilhaController, decoration: const InputDecoration(labelText: 'Anilha'))), const SizedBox(width: 12), Expanded(child: TextFormField(controller: _clubeController, maxLength: 2, decoration: const InputDecoration(labelText: 'Clube')))]),
                TextFormField(controller: _doencaController, decoration: const InputDecoration(labelText: 'Sintomas')),
                TextFormField(controller: _tratamentoController, decoration: const InputDecoration(labelText: 'Medicamento')),
                ElevatedButton(onPressed: _gravarOcorrenciaMedica, child: const Text('Salvar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
