import 'package:flutter/material.dart';
import '../models/ave_model.dart';
import '../database/db_helper.dart';

class PlantelCadastroScreen extends StatefulWidget {
  const PlantelCadastroScreen({Key? key}) : super(key: key);

  @override
  State<PlantelCadastroScreen> createState() => _PlantelCadastroScreenState();
}

class _PlantelCadastroScreenState extends State<PlantelCadastroScreen> {
  final _formKeyAve = GlobalKey<FormState>();
  final _anilhaController = TextEditingController();
  final _clubeController = TextEditingController();
  String _sexoSelecionado = 'M';
  String _segmentoFobSelecionado = 'Canário de Cor';
  String _variacaoSelecionada = 'Amarelo Mosaico';
  final _mutacaoEscritaController = TextEditingController();
  final _gaiolaController = TextEditingController();
  final _obsController = TextEditingController();
  bool _temTopete = false;

  String _origemTipoSelecionado = 'Nascido no Canaril';
  final _nomeCriadorOrigemController = TextEditingController();
  final _clubeCriadorOrigemController = TextEditingController();
  final _idPaiController = TextEditingController();
  final _idMaeController = TextEditingController();

  List<Ave> _listaAvesReal = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizarListaAves();
  }

  Future<void> _atualizarListaAves() async {
    final dados = await DBHelper.instance.buscarAvesAtivas();
    setState(() {
      _listaAvesReal = dados;
      _carregando = false;
    });
  }

  void _atualizarVariacoes(String segmento) {
    setState(() {
      _segmentoFobSelecionado = segmento;
      if (segmento == 'Canário de Cor') _variacaoSelecionada = CatalogoOficialFOB.variacoesCor.first;
      else if (segmento == 'Canário de Porte') _variacaoSelecionada = CatalogoOficialFOB.variacoesPorte.first;
      else _variacaoSelecionada = CatalogoOficialFOB.variacoesCanto.first;
    });
  }

  void _salvarCanarioNoPlantel() async {
    if (_formKeyAve.currentState!.validate()) {
      final novaAve = Ave(
        anilha: _anilhaController.text,
        clubeSigla: _clubeController.text.toUpperCase(),
        sexo: _sexoSelecionado,
        segmentoFob: _segmentoFobSelecionado,
        variacao: _variacaoSelecionada,
        mutacaoEscrita: _mutacaoEscritaController.text,
        comTopete: _temTopete,
        numeroGaiola: _gaiolaController.text,
        origemTipo: _origemTipoSelecionado,
        nomeCriadorOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _nomeCriadorOrigemController.text : null,
        clubeOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _clubeCriadorOrigemController.text.toUpperCase() : null,
        idPaiAnilha: _idPaiController.text.isNotEmpty ? _idPaiController.text : null,
        idMaeAnilha: _idMaeController.text.isNotEmpty ? _idMaeController.text : null,
        status: _sexoSelecionado == 'M' ? 'Reprodução' : 'Descanso',
        observacoes: _obsController.text,
      );

      await DBHelper.instance.salvarAve(novaAve);

      _anilhaController.clear();
      _clubeController.clear();
      _mutacaoEscritaController.clear();
      _gaiolaController.clear();
      _nomeCriadorOrigemController.clear();
      _clubeCriadorOrigemController.clear();
      _idPaiController.clear();
      _idMaeController.clear();
      _obsController.clear();

      _atualizarListaAves();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ave gravada com sucesso no SQLite!'), backgroundColor: Colors.green));
    }
  }
    @override
  Widget build(BuildContext context) {
    List<String> itensVariacao = _segmentoFobSelecionado == 'Canário de Cor' 
        ? CatalogoOficialFOB.variacoesCor 
        : (_segmentoFobSelecionado == 'Canário de Porte' ? CatalogoOficialFOB.variacoesPorte : CatalogoOficialFOB.variacoesCanto);

    return Scaffold(
      appBar: AppBar(title: const Text('🦅 Cadastro de Matrizes'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKeyAve,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("📝 Identificação Oficial (Regras FOB)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _anilhaController, decoration: const InputDecoration(labelText: 'Nº Anilha', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a anilha' : null)),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _clubeController, maxLength: 2, decoration: const InputDecoration(labelText: 'Sigla Clube (2 Letras)', border: OutlineInputBorder(), counterText: ""), validator: (val) => val!.length != 2 ? 'Use 2 letras' : null)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sexoSelecionado,
                            decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                            items: const [DropdownMenuItem(value: 'M', child: Text('Macho (🚹)')), DropdownMenuItem(value: 'F', child: Text('Fêmea (🚺)'))],
                            onChanged: (val) => setState(() => _sexoSelecionado = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _gaiolaController, decoration: const InputDecoration(labelText: 'Nº Gaiola', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe a gaiola' : null)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(title: const Text("Possui Topete?"), value: _temTopete, onChanged: (val) => setState(() => _temTopete = val!), activeColor: const Color(0xFFFFD700)),
                    const SizedBox(height: 16),
                    const Text("🧬 Catálogo Oficial da Raça", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _segmentoFobSelecionado,
                      decoration: const InputDecoration(labelText: 'Segmento Ornitológico', border: OutlineInputBorder()),
                      items: CatalogoOficialFOB.segments.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => _atualizarVariacoes(val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _variacaoSelecionada,
                      decoration: const InputDecoration(labelText: 'Variação da Raça', border: OutlineInputBorder()),
                      items: itensVariacao.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (val) => setState(() => _variacaoSelecionada = val!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _mutacaoEscritaController, decoration: const InputDecoration(labelText: 'Mutação Customizada', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    const Text("🌳 Filiação (Árvore Genealógica)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _idPaiController, decoration: const InputDecoration(labelText: 'Anilha do Pai', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _idMaeController, decoration: const InputDecoration(labelText: 'Anilha da Mãe', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("🛒 Procedência de Plantel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _origemTipoSelecionado,
                      decoration: const InputDecoration(labelText: 'Origem', border: OutlineInputBorder()),
                      items: const [DropdownMenuItem(value: 'Nascido no Canaril', child: Text('Nascido no Canaril')), DropdownMenuItem(value: 'Adquirido de Outro Canaril', child: Text('Adquirido de Outro Canaril')), DropdownMenuItem(value: 'Pet Shop / Loja de Animais', child: Text('Pet Shop / Loja'))],
                      onChanged: (val) => setState(() => _origemTipoSelecionado = val!),
                    ),
                    const SizedBox(height: 12),
                    if (_origemTipoSelecionado == 'Adquirido de Outro Canaril') ...[
                      TextFormField(controller: _nomeCriadorOrigemController, decoration: const InputDecoration(labelText: 'Nome do Canaril de Origem', border: OutlineInputBorder()), validator: (val) => val!.isEmpty ? 'Informe o nome' : null),
                      const SizedBox(height: 12),
                      TextFormField(controller: _clubeCriadorOrigemController, maxLength: 2, decoration: const InputDecoration(labelText: 'Clube de Origem (2 Letras)', border: OutlineInputBorder(), counterText: ""), validator: (val) => val!.length != 2 ? 'Use 2 letras' : null),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(controller: _obsController, maxLines: 2, decoration: const InputDecoration(labelText: 'Observações / Notas Extras', border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)), onPressed: _salvarCanarioNoPlantel, child: const Text('Confirmar e Gravar no Banco', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 24),
                    const Text("📋 Aves Gravadas no SQLite", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    _listaAvesReal.isEmpty
                        ? const Text("Banco de dados limpo.", style: TextStyle(color: Colors.grey, fontSize: 12))
                        : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _listaAvesReal.length, itemBuilder: (context, i) => Card(child: ListTile(leading: Icon(_listaAvesReal[i].sexo == 'M' ? Icons.male : Icons.female, color: _listaAvesReal[i].sexo == 'M' ? Colors.blue : Colors.pink), title: Text(_listaAvesReal[i].identificadorOficial), subtitle: Text('Gaiola: ${_listaAvesReal[i].numeroGaiola} | ${_listaAvesReal[i].variacao}')))),
                  ],
                ),
              ),
            ),
    );
  }
}
