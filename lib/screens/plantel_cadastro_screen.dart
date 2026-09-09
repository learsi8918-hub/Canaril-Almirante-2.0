import 'package:flutter/material.dart';
import '../models/ave_model.dart';

class PlantelCadastroScreen extends StatefulWidget {
  const PlantelCadastroScreen({Key? key}) : super(key: key);

  @override
  State<PlantelCadastroScreen> createState() => _PlantelCadastroScreenState();
}

class _PlantelCadastroScreenState extends State<PlantelCadastroScreen> {
  final _formKeyAve = GlobalKey<FormState>();

  // Controladores dos Campos Principais
  final _anilhaController = TextEditingController();
  final _clubeController = TextEditingController(text: 'SOGO'); // Padrão SOGO solicitado
  String _sexoSelecionado = 'M';
  String _tipoFobSelecionado = 'Canário de Porte';
  final _mutacaoController = TextEditingController();
  final _gaiolaController = TextEditingController();
  final _obsMutacaoController = TextEditingController();

  // Controle de Origem e Procedência Detalhado
  String _origemTipoSelecionado = 'Nascido no Canaril';
  final _nomeCriadorOrigemController = TextEditingController();
  final _clubeCriadorOrigemController = TextEditingController();

  // Lista simulada de aves salvas localmente
  final List<Ave> _avesCadastradas = [];

  void _salvarCanarioNoPlantel() {
    if (_formKeyAve.currentState!.validate()) {
      setState(() {
        _avesCadastradas.add(
          Ave(
            anilha: _anilhaController.text,
            clubeSigla: _clubeController.text.toUpperCase(),
            sexo: _sexoSelecionado,
            tipoFob: _tipoFobSelecionado,
            mutacaoRaca: _mutacaoController.text,
            porteDetalhe: 'Sem Topete', // Padrão inicial manipulável nas travas
            comTopete: false,
            fotoPath: '',
            numeroGaiola: _gaiolaController.text,
            origemTipo: _origemTipoSelecionado,
            nomeCriadorOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _nomeCriadorOrigemController.text : null,
            clubeCriadorOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _clubeCriadorOrigemController.text.toUpperCase() : null,
            observacaoMutacao: _obsMutacaoController.text,
          ),
        );

        // Limpa os controladores para novos cadastros
        _anilhaController.clear();
        _mutacaoController.clear();
        _gaiolaController.clear();
        _nomeCriadorOrigemController.clear();
        _clubeCriadorOrigemController.clear();
        _obsMutacaoController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🦅 Canário cadastrado com sucesso no plantel!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦅 Cadastro de Matrizes (Plantel)'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKeyAve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📝 Identificação Oficial do Pássaro", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _anilhaController,
                          decoration: const InputDecoration(labelText: 'Número da Anilha', border: OutlineInputBorder()),
                          validator: (val) => val!.isEmpty ? 'Insira a anilha' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _clubeController,
                          decoration: const InputDecoration(labelText: 'Sigla do Clube (Ex: SOGO)', border: OutlineInputBorder()),
                          validator: (val) => val!.isEmpty ? 'Insira o clube' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sexoSelecionado,
                          decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Macho (🚹)')),
                            DropdownMenuItem(value: 'F', child: Text('Fêmea (🚺)')),
                          ],
                          onChanged: (val) => setState(() => _sexoSelecionado = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _gaiolaController,
                          decoration: const InputDecoration(labelText: 'Nº da Gaiola Física', border: OutlineInputBorder()),
                          validator: (val) => val!.isEmpty ? 'Informe a gaiola' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("🧬 Classificação FOB e Raça", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _tipoFobSelecionado,
                    decoration: const InputDecoration(labelText: 'Segmento FOB', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Canário de Cor', child: Text('Canário de Cor')),
                      DropdownMenuItem(value: 'Canário de Porte', child: Text('Canário de Porte')),
                    ],
                    onChanged: (val) => setState(() => _tipoFobSelecionado = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mutacaoController,
                    decoration: const InputDecoration(labelText: 'Raça / Mutação (Ex: Arlequim Português)', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Informe a raça' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _obsMutacaoController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Observações da Mutação (Editável)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  const Text("🛒 Histórico de Procedência e Origem", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _origemTipoSelecionado,
                    decoration: const InputDecoration(labelText: 'De onde foi adquirido?', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Nascido no Canaril', child: Text('Nascido no Canaril')),
                      DropdownMenuItem(value: 'Adquirido de Outro Canaril', child: Text('Adquirido de Outro Canaril')),
                      DropdownMenuItem(value: 'Pet Shop / Loja de Animais', child: Text('Pet Shop / Loja de Animais')),
                    ],
                    onChanged: (val) => setState(() => _origemTipoSelecionado = val!),
                  ),
                  const SizedBox(height: 12),
                  if (_origemTipoSelecionado == 'Adquirido de Outro Canaril') ...[
                    TextFormField(
                      controller: _nomeCriadorOrigemController,
                      decoration: const InputDecoration(labelText: 'Nome do Criador / Canaril De Origem', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Informe o nome do criador' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clubeCriadorOrigemController,
                      decoration: const InputDecoration(labelText: 'Sigla do Clube do Criador de Origem (Ex: OZ)', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Informe o clube de origem' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                      onPressed: _salvarCanarioNoPlantel,
                      child: const Text('Cadastrar Ave no Sistema', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("📋 Registro Recente do Plantel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _avesCadastradas.isEmpty
                ? const Text("Nenhuma ave cadastrada nesta sessão.", style: TextStyle(color: Colors.grey, fontSize: 13))
            ListView.builder(shrinkWrap: true,physics: const NeverScrollableScrollPhysics(),itemCount: _avesCadastradas.length,itemBuilder: (context, index) {final ave = _avesCadastradas[index];return Card(margin: const EdgeInsets.symmetric(vertical: 4),child: ListTile(leading: Icon(ave.sexo == 'M' ? Icons.male : Icons.female, color: ave.sexo == 'M' ? Colors.blue : Colors.pink),title: Text(ave.identificadorOficial),subtitle: Text('Gaiola: ${ave.numeroGaiola} | ${ave.mutacaoRaca}\nObs: ${ave.observacaoMutacao}'),),);},),],),),);}
