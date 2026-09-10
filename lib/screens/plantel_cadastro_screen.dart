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
      final novaAve = Ave(anilha: _anilhaController.text, clubeSigla: _clubeController.text.toUpperCase(), sexo: _sexoSelecionado, segmentoFob: _segmentoFobSelecionado, variacao: _variacaoSelecionada, mutacaoEscrita: _mutacaoEscritaController.text, comTopete: _temTopete, numeroGaiola: _gaiolaController.text, origemTipo: _origemTipoSelecionado, nomeCriadorOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _nomeCriadorOrigemController.text : null, clubeOrigem: _origemTipoSelecionado == 'Adquirido de Outro Canaril' ? _clubeCriadorOrigemController.text.toUpperCase() : null, idPaiAnilha: _idPaiController.text.isNotEmpty ? _idPaiController.text : null, idMaeAnilha: _idMaeController.text.isNotEmpty ? _idMaeController.text : null, status: _sexoSelecionado == 'M' ? 'Reprodução' : 'Descanso', observacoes: _obsController.text);
      await DBHelper.instance.salvarAve(novaAve);
      _anilhaController.clear(); _clubeController.clear(); _mutacaoEscritaController.clear(); _gaiolaController.clear(); _obsController.clear();
      _atualizarListaAves();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> itensVariacao = _segmentoFobSelecionado == 'Canário de Cor' ? CatalogoOficialFOB.variacoesCor : (_segmentoFobSelecionado == 'Canário de Porte' ? CatalogoOficialFOB.variacoesPorte : CatalogoOficialFOB.variacoesCanto);

    return Scaffold(
      appBar: AppBar(title: const Text('🦅 Cadastro de Matrizes'), backgroundColor: const Color(0xFF1E1E1E)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKeyAve,
                child: Column(
                  children: [
                    TextFormField(controller: _anilhaController, decoration: const InputDecoration(labelText: 'Anilha')),
                    TextFormField(controller: _clubeController, maxLength: 2, decoration: const InputDecoration(labelText: 'Clube (2 Letras)')),
                    DropdownButtonFormField<String>(value: _segmentoFobSelecionado, items: CatalogoOficialFOB.segmentos.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => _atualizarVariacoes(val!)),
                    DropdownButtonFormField<String>(value: _variacaoSelecionada, items: itensVariacao.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (val) => setState(() => _variacaoSelecionada = val!)),
                    TextFormField(controller: _gaiolaController, decoration: const InputDecoration(labelText: 'Gaiola')),
                    ElevatedButton(onPressed: _salvarCanarioNoPlantel, child: const Text('Gravar'))
                  ],
                ),
              ),
            ),
    );
  }
}
